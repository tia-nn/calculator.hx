import Parser;
import python.Exceptions;


class Calculator {
	static public function calculate(node):Int {
		return switch (node) {
			case Num(value):
				value;
			case BinaryOperator(token, lhs, rhs) if (token == '+'):
				calculate(lhs) + calculate(rhs);
			case BinaryOperator(token, lhs, rhs) if (token == '-'):
				calculate(lhs) - calculate(rhs);
			case BinaryOperator(token, lhs, rhs) if (token == '/'):
				Std.int(calculate(lhs) / calculate(rhs));
			case BinaryOperator(token, lhs, rhs) if (token == '*'):
				Std.int(calculate(lhs) * calculate(rhs));
            case BinaryOperator(token, lhs, rhs) if (token == '%'):
                calculate(lhs) % calculate(rhs);
            case Err(i, m):
                throw new ValueError('Err.');
			case _:
				throw new ValueError('未実装');
		}
	}
}
