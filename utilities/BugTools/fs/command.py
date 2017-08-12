from BugTools.fs.parser import bfs_grammar, BFSVisitor
from BugTools.fs.passes import depstring, fsimage

import argparse, sys

def bfsbuild():
    parser = argparse.ArgumentParser(description='Tools for compiling a BugFS filesystem image and embedding it into a ROM.')

    parser.add_argument('infile', metavar='file.bfs', type=str, help='The directory listing to use.')
    parser.add_argument('outfile', metavar='file.bugfs.o', type=str, help='Where to store the RGBDS object file for the BugFS image.')

    args = parser.parse_args()

    with open(args.infile) as srcfile:
        src = srcfile.read()
        tree = bfs_grammar.parse(src + "\n") #Add a newline. Our grammar doesn't like files without ending newlines.

        mp = BFSVisitor().visit(tree)

        datum = fsimage(mp).bytes

        with open(args.outfile, 'wb') as dstfile:
            dstfile.write(datum)

def bfsdeps():
    parser = argparse.ArgumentParser(description='Tool for extracting a list of dependencies from a .bfs file (for Make).')

    parser.add_argument('infile', metavar='file.bfs', type=str, help='The directory listing to use.')

    args = parser.parse_args()

    with open(args.infile) as srcfile:
        src = srcfile.read()
        tree = bfs_grammar.parse(src + "\n") #Add a newline. Our grammar doesn't like files without ending newlines.

        mp = BFSVisitor().visit(tree)

        print(depstring(mp))
