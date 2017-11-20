module lang::rsvp::Util
import ParseTree;
import IO;
import Set;
import Node;
import lang::rsvp::Rsvp;
import lang::rascal::format::Escape;
import String;

public str applToStr(a:appl(p,_)) = "<prodToStr(p)> := \"<replaceAll(unparse(a),"\n","\\n")[..20]>\"";
public str prodToStr(prod(s,as,_)) = "<printSymbol(s, true)> = <intercalate(", ", [printSymbol(a, true) | a <- as])>;";
public str prodToStr(regular(s)) = "<printSymbol(s, true)>";

public void showAmb(Tree t) {
	top-down-break visit(t) {
		case x:amb(as): {
			println("Ambiguity: ");
			as = visit(as) { case amb(ts) => getOneFrom(ts) }
			for(a <- delAnnotationsRec(as)) {
				println(applToStr(a));
				for(s <- a.args) {
					println("\t<applToStr(s)>");
				}
				//println("    <[a]>");
			}
		}
	}
}

public str bold(str s) = "\a1b\a5b1m<s>\a1b\a5b0m";
public str italic(str s) = "\a1b\a5b4m<s>\a1b\a5b0m";

public str toAstStr(start[RsvpDoc] d) = toAstStr(d.top);
	
public str toAstStr((RsvpDoc)`<Module? m><HtmlPart h>`) {
	return "<bold(unparse(m))><italic(toAstStr(h))>";
}

public str toAstStr((HtmlPart)`<HtmlDoctype dt><Htmls hs>`) {
	return "<unparse(dt)><toAstStr(hs)>";
}

public str toAstStr((Htmls)`<Html* hs>`) {
	return intercalate("", [toAstStr(h) | Html h <- hs.args]);
}
public str toAstStr(LAYOUTLIST l) = unparse(l);


public str toAstStr((Html)`\<%<Expression e>%\>`) {
	return bold(unparse(visit(e) {
		case (Expression)`%\><Htmls hs>\<%`: {
			s = toAstStr(hs);
			insert parse(#Expression, "<quote(s)>");
		}
	}));
}

public str toAstStr(Html h) = unparse(h);
