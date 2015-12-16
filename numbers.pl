% %%
%
% numbers.pl
%
% %%
%
% COMP90048
% Declarative Programming
% Project 2
%
% Franz Neulist Carroll
% 391929
%
% October 2015
%
% %%
%
% A small prolog program to solve number puzzles.
% Uses the constraint logic programming over finite domains (clpfd) library.
%
% A brief explanation of the clpfd library - paricular to its usage in this program:
% The clpdf library allows a succinct solution to this project. It contains the functionality
% for constraining the variables for the unknown entries in the puzzle and assigning values 
% satisfying the constraints.
% By use of the ins/2 function, the unknown entries are given domains - these are possible 
% integer values that the entries may be. In this case, they are integers from 1 to 9, as the
% puzzle requires. 
% Once the unknown entries are given domains, constraints may be set on them. The puzzle has 
% three constraints:
% (1)   The entries along the diagonal must be the same.
% (2)   The digits in each row and column must be distinct.
% (3)   The sum or the product of the tail of each row and column must equal the head of 
%       the row or the column.
% For (1), no clpfd magic is needed - simply unify the varibles for the entries on the
% diagonal.
% For (2), clpfd provides a all_distinct/1 predicate. This constrains the entries to be
% distinct. I'm guessing that it wraps up traversing the list and setting every element
% not equal to each other.
% For (3), clpfd provides an or and a equals predicate, namely infix #\//2 and #=/2 
% respectivly. By binding variables to the sum and to the product of the tail of
% a row or column, we may use the or and equals predicate to apply
% the constraint by:
%   (H #= S) #\/ (H #= P)
%   where H is the head of row or column and ground, S is bound to sum of row or column
%   and P is bound to product of row or column.
% Now that the constraints have been applied, the propogation and labelling steps remains.
% Propogation involves reducing the domain of each unknown entry by applying the constraints.
% clpfd does this for us with the label/1 predicate. Each constraint is applied to an unknown
% variable, reducing its domain to get the solution. Remember, the project requires this program
% to solve puzzles with only one solution, so by this assumption, the domains of each unknown
% variable will be reduced to one number. If a puzzle is passed that has no solution, then one
% or more of the unknown variables will have its range reduced to nothing (i.e. empty set) 
% and the label/1 predicate will fail. If a puzzle has more than one solution, then at least
% one of the unknown variables will have a domain larger than one, and both solutions will 
% be returned if asked for.
% Once the propogation is complete, it remains to label the unknown variables - to assign 
% values to them from their domains. clpfd does this for us again with the label/1 predicate.
% It will, one by one, pick an element from the unknown variable's domains and unify it with
% the variable - making it ground. It does this in some particular order, and this order can 
% be changed by using another predicate - see the docs.
% As you can now see, the clpfd library essentially does the project for me. Its VERY fast too.
%
% Program abstract:
% As the puzzle_solution/1 predicate exhibits, the program is divided into 6 steps,
% (1)   Unifying the squares along the diagonal of the puzzle to satisfy the first 
%       constraint. This does not require any clpfd magic.
% (2)   Set the domains of the unknown entries, preparing them for the second and 
%       third constraints. The domains are integers from 1 to 9.
% (3)   Transposing the entire puzzle to access the columns. A list of columns allows
%       a simpler implementation of the second and third constraints. This uses
%       clpfd transpose/2
% (4)   Setting the entries in every row and column to be distinct to satisfy the 
%       second constraint. This uses clpfd all_disinct/1.
% (5)   Setting the sum or the product of every row and column to be the first entry
%       to satisfy the third constraint. This uses clpfd #\//2 (or) and #=/2 (equals).
% (6)   Now that all the constraints are applied, we may propogate adn the puzzle is 
%       solved. It remainsto assign values to the unknown entries from their domains.
%       This uses clpfd label/1.
%
% %%

:- ensure_loaded(library(clpfd)).

% %%
% puzzle_solution
% The main predicate of the program.
% Argument: A list of lists of integers - the puzzle.
% %%
puzzle_solution([R|Rs]) :-
    
    % R is the first row - containing constraints for the columns.
    % Rs is a list of the remaining rows.

    % Pass to a predicate that will apply the first constraint -
    % namely, unify the squares along the diagonal.
    unify_diagonal(Rs),

    % Pass to a predicate that will set the domains to the unknown entries.
    set_domains(Rs),

    % This predicate will transpose the puzzle, returning a list of the columns.
    transpose([R|Rs], [_|Cs]),
    % Note that the head of the columns - containing constraints for the rows -
    % is not required for any use.
    % Cs is a list of the remaining columns.

    % Map a predicate that will apply the second constraint over the row list
    % and column list.
    % The second constraint is that the digits in each row and column must be distinct.
    maplist(set_distinct, [Rs, Cs]),

    % Map a predicate that will apply the third constraint over the row list
    % and column list.
    % The third constraint is that the sum or the product of each row and column must 
    % equal the head entry.
    maplist(set_sum_or_product, [Rs, Cs]),

    % All the constraints have now been applied and the puzzle is solved.
    % It remains to label the domains - to assign values to the unknown entries from 
    % their domains.
    % Pass to a predicate to assign values to the unknown entries.
    assign_values(Rs).

% %%
% unify_diagonal
% unify the squares along the diagonal in the puzzle.
% This predicate extracts the first diagonal entry in the puzzle from the first row
% in the list of rows and passes it and the remaining rows to a helper function.
% %%
unify_diagonal([X|Xs]) :-
    
    % X is the first row.
    % Xs is a list of the remaining rows.

    % D is bound to the diagonal elements. Here, it is being bound to the first diagonal
    % entry in the first row. Later, it will be bound to the remaining diagonal entries.
    % The first diagonal is the second element of the first row. Recall that the
    % first entry is the sum or product constraint.
    I is 2,
    nth1(I, X, D),

    % Pass to the helper function.
    % Pass the remaining rows (Xs). 
    % Pass the index of the diagonal element in the next row. This is 3 - the first
    % element of the second row is the sum or product constraint, so the diagonal in the
    % second row is the third element.
    I2 is 3,
    % Pass D - it is bound to the first diagonal entry and is to be bound to the rest.
    unify_diagonal_h(Xs, I2, D).

% Helper function - base case: empty list - bottom of recursion.
% Do nothing.
unify_diagonal_h([], _, _).

% Helper function - general case.
unify_diagonal_h([X|Xs], I, D) :-

    % X is the head of the list of rows.
    % Xs is the remaining rows.
    % I is the index of the diagonal entry.
    % D is bound to all previous diagonal entries.

    % The diagonal is at I.
    % Bind the diagonal (E) to the previous diagonals (D). 
    nth1(I, X, E),
    E = D,

    % Recurse.
    % Pass the remaining rows (Xs).
    % Pass the index of the diagonal element in the next row. This is 3 - the first
    % The diagonal in the next row is at I + 1.
    I2 is I+1,
    % Pass D - to be bound to the remaining diagonals.
    unify_diagonal_h(Xs, I2, D).
    
% %%
% set_domains
% Set integer domains to the squares of the puzzle.
% Domains are integers from 1 to 9.
% %%

% Base case: empty list - bottom of recursion.
% Do nothing.
set_domains([]).

% General case.
set_domains([[_|Xs]|Ys]) :-

    % Ignore the head of the row - it is a sum or product constraint not an unknown.
    % Xs is a list of entries in the row.
    % Ys is a list of the remaining rows.
    
    % Exclude ground squares - they are known and hence do not need domains.
    exclude(ground, Xs, Zs),
    % Zs is a list of non-ground entries in the row.

    % Set the domains.
    % Domains are integers from 1 to 9.
    % ins/2 from clpfd library.
    % ins/2 sets the domains of Zs to be 1..9.
    % See clpdf explanation at start of file.
    Zs ins 1..9,

    % Recurse.
    % Pass the remaining rows (Ys).
    set_domains(Ys).

% %%
% set_distinct.
% Set the entries in each row or column to be distinct.
% To satisfy the second constraint.
% %%

% Base case: empty list - end of recursion.
% Do nothing.
set_distinct([]).

% General case.
set_distinct([[_|Xs]|Ys]) :-

    % Ignore the head of the row - it is a constraint not an unknown.
    % Xs is a list of entries in the row or column.
    % Ys is a list of the remaining rows or columns.

    % Use all_distinct/1 to apply the constraint.
    % all_distinct/1 from clpfd library.
    % See clpdf explanation at start of file.
    all_distinct(Xs),

    % Recurse.
    % Pass the remaining rows or columns (Ys).
    set_distinct(Ys).

% %% 
% set_sum_or_product
% Set the sum or the product of each row and column to equal the 
% head entry.
% To satisfy the third constraint.
% %%

% Base case: empty list - end of recursion.
% Do nothing.
set_sum_or_product([]).

% General case.
set_sum_or_product([[X|[Y|Ys]]|Zs]) :-

    % X is the head of the row or column.
    % Y is the second entry in the row or column.
    % Ys is the remaining entries in the row or column.
    % Zs is a list of the remaining rows or columns.

    % Pass to a predicate to constrain the sum and product of the row 
    % or column.
    % S is bound to the sum.
    % P is bound to the product.
    list_sum_and_product(Ys, Y, Y, S, P),

    % Apply the constraint.
    % #\//2 and #=/2 from clpfd library.
    % #\//2 is a logical or.
    % #=/2 is a logical equals.
    % See clpdf explanation at start of file.
    % X is the sum S or the product P.
    (X #= S) #\/ (X #= P),

    % Recurse.
    % Pass the remaining rows or columns (Zs).
    set_sum_or_product(Zs).

% %%
% list_sum_and_product
% Constrain the sum and the product of a list.
% Note well, this CONSTRAINS the sum and the product and
% returns variables bound the sum and the products.
% It does not calculate the ground sum nor the ground product.
% %%

% Base case: empty list - end of recursion.
list_sum_and_product([], AS, AP, S, P) :-

    % AS is the accumulated sum.
    % AP is the accumulated product
    % S is to be bound to the sum.
    % P is to be bound to the product.

    % Since the recursion is complete,
    % bound the sum (S) and the product (P) to
    % their respective accumulators.
    S = AS,
    P = AP.

% General case:
list_sum_and_product([X|Xs], AS, AP, S, P) :-

    % X is the head of the list.
    % Xs is the tail of the list.
    % AS is the accumulator for the sum.
    % AP is the accumulator for the product.
    % Accumulators are used to enable this predicate to
    % be tail-recursive.
    % S is to be bound to the sum.
    % P is to be bound to the product.

    % Constrain the accumulators for the next recursion (AS1 and AP1) to
    % be the sum and product of the current accumulators (AS and AP) and 
    % the current head (X).
    AS1 = AS+X,
    AP1 = AP*X,

    % Recurse.
    % Pass the tail of the list (Xs).
    % Pass the new accumulators (AS1 and AP1).
    % Pass S and P to be bound at the end of the recursion.
    list_sum_and_product(Xs, AS1, AP1, S, P).

% %%
% assign_values
% Assigns values to variables with domains in the rows of the puzzle.
% %%

% Base case: empty list - end of recursion.
assign_values([]).

% General case.
assign_values([[_|Xs]|Ys]) :-

    % Ignore the head of the row - it is a sum or product constraint and is 
    % obviously ground.
    % Xs is a list of entries in the row.
    % Ys is a lits of the remaining rows.

    % Exclude ground entries of the row - as they are ground then they can 
    % not have any domains to label.
    exclude(ground, Xs, Zs),
    % Zs is a list of non-ground entries in the row.
 
    % Label the non-ground entries.
    % label/1 from clpfd library.
    % See clpdf explanation at start of file.
    % Assign values in their domains to the variables - they are now ground.
    label(Zs),

    % Recurse.
    % Pass the remaining rows (Ys).
    assign_values(Ys).

% %%
% Thank you very much for teaching me! I really enjoyed this subject.
% %%
