module lang::rsvp::Engine
import ParseTree;
import IO;
import Set;
import Node;
import lang::rsvp::Rsvp;
import lang::rascal::format::Escape;
import String;
import util::Reflective;
import util::Webserver;

public Module toRascal(start[RsvpDoc] d) = toRascal(d.top);
	
public Module toRascal((RsvpDoc)`<Module m><HtmlPart h>`) 
	= m;

public list[str] toRascalCmds(RsvpDoc doc) =
	toRascalCmds(doc, get("/"));
	
public list[str] toRascalCmds((RsvpDoc)`<HtmlPart h>`, Request req) {
	return ["import IO;",
			"import util::Webserver;",
	        "public str __flatten(value v) {" +
			"  switch(v) {" +
			"  		case list[str] ss: return (\"\" | it+s | s \<- ss);" +
			" 		case list[value] ss: return (\"\" | it+__flatten(s) | s \<- ss);" +
			"  		default: return \"\<v\>\";" +
			"  	}" +
			"}",
			"<toRascal(h)>",
			"println(generate(<req>));"];
}
public Module toRascal((RsvpDoc)`<HtmlPart h>`) {
	d = toRascal(h); 
	return   (Module)`module foo
	                 '
                     'public str __flatten(value v) {
					 '  switch(v) {
					 '  		case list[str] ss: return ("" | it+s | s \<- ss);
					 '  		case list[value] ss: return ("" | it+__flatten(s) | s \<- ss);
					 '  		default: return "\<v\>";
					 '  	}
					 '}
					 '
					 '<Toplevel d>`;
}

public Toplevel toRascal((HtmlPart)`<HtmlDoctype dt><Htmls hs>`) {
	Expression e = toRascal(hs);
	return (Toplevel)`public str generate(Request httpRequest) =
	                 '    <Expression e>;`;
	}

public Expression toRascal((Htmls)`<Html* hs>`) {
	return combine([toRascal(h) | h <- hs.args]);
}

public Expression combine(list[Expression] exprs) {
	switch(exprs) {
	case []: return (Expression)`""`;
	case [Expression e1]: return e1;
	case [(Expression)`"<StringCharacter* ss1>"`,
		  (Expression)`"<StringCharacter* ss2>"`, *es]:
		  	return combine([(Expression)`"<StringCharacter* ss1><StringCharacter* ss2>"`, *es]);
	case [ e1, *es]: {
		e2 = combine(es);
		return (Expression)`<Expression e1>
	    	               '  + <Expression e2>`;
		}
	}
}


public Expression toRascal(LAYOUTLIST l)
	= parse(#Expression, "<quote(unparse(l))>");

public Expression toRascal((Html)`\<%<Expression e>%\>`) {
	subE = visit(e) {
		case (Expression)`%\><Htmls hs>\<%`: {
			subE = toRascal(hs);
			insert (Expression)`__flatten(<Expression subE>)`;
		}
	};
	return (Expression)`__flatten(<Expression subE>)`;
}

public default Expression toRascal(Tree h)
	= parse(#Expression, "<quote(unparse(h))>");


public str expand(loc doc) = expand(doc, get("/"));

public str expand(start[RsvpDoc] doc) = expand(doc.top, get("/"));
	
public str expand(RsvpDoc doc) = expand(doc, get("/"));

public str expand(loc doc, Request req) = expand(parse(#start[RsvpDoc], doc), req);

public str expand(start[RsvpDoc] doc, Request req) = expand(doc.top, req);
	
public str expand(RsvpDoc doc, Request req) {
	<r,out,err> = evalCommands(toRascalCmds(doc, req), |unknown:///|)[-1];
	if(err != "")
		throw err;
	else
		return out;
}
