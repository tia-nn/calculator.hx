import Tokenizer;
import haxe.ds.Option;

enum Node {
	Definition(funcs:Array<Node>);
	Func(name:String, v:Option<String>, exp:Node);
	If(cond:Node, lhs:Node, rhs:Node);
	Num(value:Int);
	Var(name:String);
	Call(name:String, v:Option<Node>);
	UnaryOperator(Token:String, hs:Node);
	BinaryOperator(Token:String, lhs:Node, rhs:Node);
	Err(index:Int, message:String);
}

class Parser {
	var tokens:Array<Token>;
	var index:Int;

	public function new(tokens:Array<Token>) {
		this.tokens = tokens;
		this.index = 0;
	}

	public function parse() {
		return this.definition();
	}

	private function definition():Node {
		var funcs = new Array<Node>();

		while (!Type.enumEq(this.tokens[this.index], Token.EoF)) {
			funcs.push(this.func());
		}

		return Definition(funcs);
	}

	private function func():Node {
		var name:String;
		var v:Option<String>;
		var exp:Node;
		try {
			switch (this._ide()) {
				case Some(s):
					name = s;
				case _:
					throw 'no function name';
			}
			if (!this._ope_char('(')) throw 'no (';
			v = this._ide();
			if (!this._ope_char(')')) throw 'no )';
			if (!this._ope_char('=')) throw 'no =';
			exp = this.expression();
			if (!this._ope_char(';')) throw 'no ;';
		} catch (message:String) {
			this.index ++;
			return Err(this.index-1, message);
		}

		return Func(name, v, exp);
	}

	private function expression():Node {
		var node = this.if_();

		return node;
	}

	private function if_():Node {
		return switch (this.tokens[this.index]) {
			case If:
				this.index ++;
				if (!this._ope_char('(')) throw 'no (';
				var exp = this.expression();
				if (!this._ope_char(')')) throw 'no )';
				var lhs = this.expression();
				if (!this._ope_char(':')) throw 'no :';
				var rhs = this.expression();
				If(exp, lhs, rhs);
			case _:
				this.add();
		}
	}

	private function add():Node {
		var node = this.mul();
		while (true) {
			switch (this.tokens[this.index]) {
				case Token.Operator(token) if (token == '+'):
					this.index++;
					node = BinaryOperator('+', node, this.mul());
				case Token.Operator(token) if (token == '-'):
					this.index++;
					node = BinaryOperator('-', node, this.mul());
				case _:
					break;
			}
		}

		return node;
	}

	private function mul():Node {
		var node = this.cons();

		while (true) {
			switch (this.tokens[this.index]) {
				case Token.Operator(token) if (token == '*'):
					this.index++;
					node = BinaryOperator('*', node, this.cons());
				case Token.Operator(token) if (token == '/'):
					this.index++;
					node = BinaryOperator('/', node, this.cons());
				case Token.Operator(token) if (token == '%'):
					this.index++;
					node = BinaryOperator('%', node, this.cons());
				case _:
					break;
			}
		}

		return node;
	}

	private function cons():Node {
		var node:Option<Node> = None;

		while (true) {
			switch (this.tokens[this.index]) {
				case Token.Operator(token) if (token == '('):
					this.index++;
					node = Some(this.expression());
					if (!Type.enumEq(this.tokens[this.index], Token.Operator(')'))) {
						node = Some(Err(this.index, ')が無い'));
					}
					this.index++;
				case _:
					break;
			}
		}

		return switch (node) {
			case Some(n):
				n;
			case None:
				this.call();
		}
	}

	private function call():Node {
		var name = this._ide();

		switch (name) {
			case None:
				return this.num();
			case Some(name):
				try {
					var exp:Node;
					if (!this._ope_char('(')) throw 0;
					if (this._ope_char(')'))
						return Call(name, None); 
					else
						exp = this.expression();
						if (!this._ope_char(')')) throw 'no )'
						else return Call(name, Some(exp));
				} catch (_:Int) {
					return Var(name);
				} catch (message:String) {
					this.index ++;
					return Err(this.index-1, message);
				}
		}
	}

	private function num():Node {
		return switch (this.tokens[this.index]) {
			case Token.Num(value):
				this.index++;
				Num(value);
			case _:
				this.index ++;
				return Err(this.index-1, '知らないトークン');
		}
	}

	private function _ide():Option<String> {
		return switch (this.tokens[this.index]) {
			case Token.Ide(v):
				this.index ++;
				Some(v);
			case _:
				None;
		}
	}

	private function _ope_char(op:String):Bool {
		return switch (this.tokens[this.index]) {
			case Token.Operator(token) if (token == op):
				this.index ++;
				true;
			case _:
				false;
		}
	}
	
}
