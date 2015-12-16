# README #

This is a number puzzle solver written in Prolog.

I wrote this during my studies at the University of Melbourne for the class Decalrative Programming.

A number puzzle is a square grid of squares, each to be filled in with a single digit 1–9 (zero is not permitted) satisfying these constraints:

each row and each column contains no repeated digits;
all squares on the diagonal line from upper left to lower right contain the same value; and
the heading of reach row and column (leftmost square in a row and topmost square in a column) holds either the sum or the product of all the digits in that row or column 

Note that the row and column headings are not considered to be part of the row or column, and so may be filled with a number larger than a single digit. The upper left corner of the puzzle is not meaningful.

When the puzzle is originally posed, most or all of the squares will be empty, with the headings filled in. A puzzle will only have one solution. The goal of the puzzle is to fill in all the squares according to the rules.

Here is an example 3x3 puzzle as posed (above) and solved (below) :

![example_puzzle.png](https://bitbucket.org/repo/y6K4Kk/images/3202718307-example_puzzle.png)

![example_puzzle_solved.png](https://bitbucket.org/repo/y6K4Kk/images/3094270424-example_puzzle_solved.png)

Usage:

Requires swi-pl.

Load Proj2.pl into swi-pl

then for example:

    ?- Puzzle=[[0,14,10,35],[14,_,_,_],[15,_,_,_],[28,_,1,_]], 
    |    puzzle_solution(Puzzle).
    Puzzle = [[0, 14, 10, 35], [14, 7, 2, 1], [15, 3, 7, 5], [28, 4, 1, 7]] ;
    false.

franzneulistcarroll@gmail.com