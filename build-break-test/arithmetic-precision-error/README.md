## ARITHMETIC PRECISION ERROR
This is an error that is present from any calculation that results in a nonintegral value between 0 and 1. The result will be represented as 0 when you use integer types like u64 or u128.

Just like solidity, move will round off the decimals and this might lead to an error where the result of a calculation becomes 0

One of the right approaches for these kinds of calculation is to first multiply then divide as the last calculation.

### Toy Example
In this simple example, I've created a simple arithmetical codebase to calculate b*a/c where c>a>b.

Take for example if a=40, b=10 and c=100. The correct calculation will be (40/100) then multiply the result by 10. But the result of this calculation in move will be 0, due to (40/100) being rounded off to 0.
But if you calculate it by multiplication first (40*10) then divide the result by 100, the result will be 4.

Provided the division first will lead to a rounding off of 0 this error will be present and can lead to serious issues.
You can test this using the code provided in the source file using different numbers to see.

### Real-World Case Scenario
We are going to use Aave's codebase


