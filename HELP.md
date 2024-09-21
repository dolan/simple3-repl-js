# Simple 3 Language

Simple 3 is a small, interpreted language designed for learning about programming language concepts. It features basic arithmetic, string manipulation, input/output, loops, conditionals, and functions.

## Basic Constructs

### Variables

* Variables are declared and assigned values using the `=` operator.
* Variable names must start with a letter and can contain letters and numbers.
* Example:
  ```
  x = 10
  name = "Alice"
  ```

### Expressions

* Expressions are combinations of variables, literals, and operators that evaluate to a value.
* Operators include:
  * Arithmetic: `+`, `-`, `*`, `/`
  * Comparison: `>`, `<`, `>=`, `<=`, `==`, `<>` (not equals)
  * Logical: `&` (and)
* Example:
  ```
  5 + 3
  x * 2
  name == "Bob"
  ```

### Statements

* Statements are instructions that perform actions.
* Common statements include:
  * `print`: Prints a value to the console.
  * `read`: Reads input from the user.
  * `loop`: Executes a block of statements repeatedly.
  * `while`: Executes a block of statements as long as a condition is true.
  * `for`: Executes a block of statements a specified number of times.
  * `if`: Executes a block of statements if a condition is true.
  * `if else`: Executes one block of statements if a condition is true, and another block if it's false.
  * `function`: Defines a function.
  * `return`: Returns a value from a function.

### Examples

#### Printing Values

```
print 5 + 3
print "Hello, world!"
```

#### Reading Input

```
print "Enter your name: "
read name
print "Hello, " + name + "!"
```

#### Loops

```
loop i = 1 to 5
  print i
end
```

#### Conditionals

```
if x > 10 then
  print "x is greater than 10"
end
```

#### Functions

```
function add(a, b) begin
  return a + b
end

print add(5, 7)
```

## Running the REPL

1. Open `index.html` in a web browser.
2. Enter Simple 3 code in the input field.
3. Click the "Run" button to execute the code.
4. The output will be displayed below the input field.

Enjoy exploring the Simple 3 language!
