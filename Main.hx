import Tokenizer;
import Parser;
import Calculator;


class Main {
    public static function main() {
        var code = "23 + 34 * (10 / 2) ";
        var code2 = "(23 + 34) * (17 % 6)";

        var tokenizer = new Tokenizer(code);
        var tokens = tokenizer.tokenize();
        var parser = new Parser(tokens);
        var node = parser.parse();
        var ans = Calculator.calculate(node);

        
        var tokenizer2 = new Tokenizer(code2);
        var tokens2 = tokenizer2.tokenize();
        var parser2 = new Parser(tokens2);
        var node2 = parser2.parse();
        var ans2 = Calculator.calculate(node2);

        trace(ans);
        trace(ans2);
    }
}
