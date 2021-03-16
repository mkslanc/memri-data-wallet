import 'dart:core';
import 'dart:ffi';

class _Operator {
    _Operator(ExprOperator exprOperator, int int);
}

class _Bool extends ExprToken {
    _Bool(bool boolean, int int);
}

class _Identifier {
    _Identifier(String string, int int);
}

class _Number {
    _Number(Double double, int int);
}

class _Negation {
    _Negation(int int);
}

class _Comma {
    _Comma(int int);
}

class _ParensOpen {
    _ParensOpen(int int);
}

class _ParensClose {
    _ParensClose(int int);
}

class _CurlyBracketOpen {
    _CurlyBracketOpen(int int);
}

class _CurlyBracketClose {
    _CurlyBracketClose(int int);
}

class _BracketOpen {
    _BracketOpen(int int);
}

class _BracketClose {
    _BracketClose(int int);
}

class _String {
    _String(String string, int int);
}

class _Period {
    _Period(int int);
}

class _Other {
    _Other(String string, int int);
}

class _EOF {
}

class ExprToken {
    static final Operator = (ExprOperator exprOperator, int int) => _Operator(exprOperator, int);
    static final Bool = (bool boolean, int int) => _Bool(boolean, int);
    static final Identifier = (String string, int int) => _Identifier(string, int);
    static final Number = (Double double, int int) =>_Number(double, int);
    static final Negation = (int int) => _Negation(int);
    static final Comma = (int int) => _Comma(int);
    static final ParensOpen = (int int) => _ParensOpen(int);
    static final ParensClose = (int int) => _ParensClose(int);
    static final CurlyBracketOpen = (int int) => _CurlyBracketOpen(int);
    static final CurlyBracketClose = (int int) => _CurlyBracketClose(int);
    static final BracketOpen = (int int) => _BracketOpen(int);
    static final BracketClose = (int int) => _BracketClose(int);
    static final StringD = (String string, int int) => _String(string, int);
    static final Period = (int int) => _Period(int);
    static final Other = (String string, int int) => _Other(string, int);
    static final EOF = () => _EOF();
}

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

const Mode = {
    "idle": 0,
    "keyword": 10,
    "number": 20,
    "string": 30,
    "escapedString": 35
};
