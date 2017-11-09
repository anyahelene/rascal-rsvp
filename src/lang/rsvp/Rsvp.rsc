module lang::rsvp::Rsvp
extend lang::rascal::\syntax::Rascal;

import ParseTree;

syntax Expression = QuotedHtml;

start syntax RsvpDoc
	= Module? HtmlPart
	;
	
syntax HtmlPart
	= HtmlDoctype Htmls htmls 
		/*!>> [\t-\r\ \u0085\u00a0\u1680\u180e\u2000-\u200a\u2028-\u2029\u202f\u205f\u3000] 
		!>> "//"
		!>> "/*"*/
	;

syntax Htmls 
	= Html*
	;
	
syntax Html
	= QuotedRascal
	| @category="Constant" HtmlChars
	| @category="MetaVariable" TagStart TagChars TagEnd
	; 

syntax QuotedRascal 
	= "\<%" Expression expr "%\>";

lexical HtmlChars
	= ![\<]+ !>> ![\<] 
	;
	
lexical TagStart
	= [\<] !>> [%]
	;

lexical TagEnd
	= [%] !<< [\>]
	;

lexical TagChars
	= ![\<\>] !<< ![\<\>]* !>> ![\<\>]
	;
	

syntax QuotedHtml
	= "%\>" Htmls htmls "\<%"
	;
lexical HtmlDoctype
	= "\<!DOCTYPE" ![\>]* "\>"
	;
