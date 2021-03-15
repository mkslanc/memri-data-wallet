import 'dart:ffi';

class Operator {
    Operator(ExprOperator exprOperator, Int8 int);
}

class Bool {
    Bool(bool boolean, Int8 int);
}

class Identifier {
    Identifier(String string, Int8 int);
}

class Number {
    Number(Double double, Int8 int);
}

class Negation {
    Negation(Int8 int);
}

class Comma {
    Comma(Int8 int);
}

class ParensOpen {
    ParensOpen(Int8 int);
}

class ParensClose {
    ParensClose(Int8 int);
}

class CurlyBracketOpen {
    CurlyBracketOpen(Int8 int);
}

class CurlyBracketClose {
    CurlyBracketClose(Int8 int);
}

class BracketOpen {
    BracketOpen(Int8 int);
}

class BracketClose {
    BracketClose(Int8 int);
}

class String {
    String(String string, Int8 int);
}

class Period {
    Period(Int8 int);
}

class Other {
    Other(String string, Int8 int);
}

class EOF {
}

const ExprToken = [
    Operator,
    Bool,
    Identifier,
    Number,
    Negation,
    Comma,
    ParensOpen,
    ParensClose,
    CurlyBracketOpen,
    CurlyBracketClose,
    BracketOpen,
    BracketClose,
    String,
    Period,
    Other,
    EOF
];

class ExprOperator {
    static const ConditionStart = "?";
    static const ConditionElse = ":";
    static const ConditionAND = "AND";
    static const ConditionOR = "OR";
    static const ConditionEquals = "=";
    static const ConditionNotEquals = "!=";
    static const ConditionGreaterThan = ">";
    static const ConditionGreaterThanOrEqual = ">=";
    static const ConditionLessThan = "<";
    static const ConditionLessThanOrEqual = "<=";
    static const Plus = "+";
    static const Minus = "-";
    static const Multiplication = "*";
    static const Division = "/";

    static int? precedence(operator) {
        switch (operator) {
            case ExprOperator.ConditionStart:
                return 5;
            case ExprOperator.ConditionElse:
                return 10;
            case ExprOperator.ConditionAND:
                return 20;
            case ExprOperator.ConditionOR:
                return 30;
            case ExprOperator.ConditionEquals:
                return 35;
            case ExprOperator.ConditionNotEquals:
                return 35;
            case ExprOperator.ConditionGreaterThan:
                return 35;
            case ExprOperator.ConditionGreaterThanOrEqual:
                return 35;
            case ExprOperator.ConditionLessThan:
                return 35;
            case ExprOperator.ConditionLessThanOrEqual:
                return 35;
            case ExprOperator.Plus:
                return 40;
            case ExprOperator.Minus:
                return 40;
            case ExprOperator.Multiplication:
                return 50;
            case ExprOperator.Division:
                return 50;
        }
    }
}