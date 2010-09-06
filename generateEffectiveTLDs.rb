#
# Florian Sager, 06.08.2008, sager@agitos.de
#
# Ruby translation:
# TAGAMI Yukihiro, 2010-09-06, tagami.yukihiro@gmail.com
#

require 'open-uri'

url = 'http://mxr.mozilla.org/mozilla-central/source/netwerk/dns/effective_tld_names.dat?raw=1'

# Does $search start with $startstring?

def startsWith(search, startstring)
	return search.index(startstring) == 0
end

# Does $search end with $endstring?

def endsWith(search, endstring)
	return search.index(endstring) == search.length - endstring.length
end


def buildSubdomain(node, tldParts)

	dom = tldParts.pop().strip()

	isNotDomain = false
	if startsWith(dom, "!")
		dom = dom[1..dom.length]
		isNotDomain = true
	end

	if !(node.has_key?(dom))
		if isNotDomain
			node[dom] = {"!" => ""}
		else
			node[dom] = {}
		end
	end

	if !isNotDomain && tldParts.length > 0
		buildSubdomain(node[dom], tldParts)
	end
end

def printNode(key, valueTree, isAssignment)

	if isAssignment
		print key + " = {"
	else
		if key == "!"
			print "'!' => {}"
			return
		else
			print "'" + key + "' => {"
		end
	end

	keys = valueTree.keys
	keys.sort!

	0.upto(keys.length - 1) do |i|

		key = keys[i]

		printNode(key, valueTree[key], false)

		if i+1 != valueTree.length
			print ",\n"
		end
		i += 1
	end

	print "}"
end

tldTree = {}
domain_list = OpenURI.open_uri(url).read()
lines = domain_list.split("\n")
licence = true

for line in lines

	if licence && startsWith(line, "//")

		print "# " + line[2..line.length] + "\n"

		if startsWith(line, "// ***** END LICENSE BLOCK")
			licence = false
			print "\n"
		end
		next;
	end

	if startsWith(line, "//") || line == ''
		next;
	end

	# this must be a TLD
	tldParts = line.split('.')

	buildSubdomain(tldTree, tldParts)
end

print "module EffectiveTLDs\n"
printNode("TldTree", tldTree, true)
print "\n"
print "end\n"

