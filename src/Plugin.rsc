module Plugin

import util::IDE;
import ParseTree;
import IO;
import lang::rsvp::Rsvp;

void main() {
   registerLanguage("RSVP", "rsvp", Tree(str src, loc l) {
     pt = parse(#start[RsvpDoc], src, l);
     
     return pt;
   });
}
