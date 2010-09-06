# <@LICENSE>
# Licensed to the Apache Software Foundation (ASF) under one or more
# contributor license agreements.  See the NOTICE file distributed with
# this work for additional information regarding copyright ownership.
# The ASF licenses this file to you under the Apache License, Version 2.0
# (the "License"); you may not use this file except in compliance with
# the License.  You may obtain a copy of the License at:
# 
#     http://www.apache.org/licenses/LICENSE-2.0
# 
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
# </@LICENSE>
#
# Florian Sager, 2009-01-11, sager@agitos.de
#
# Ruby translation:
# TAGAMI Yukihiro, 2010-09-06, tagami.yukihiro@gmail.com
#

#getRegisteredDomain(signingdomain)
#
#Remove subdomains from a signing domain to get the registered domain.
#
#dkim-reputation.org blocks signing domains on the level of registered domains
#to rate senders who use e.g. a.spamdomain.tld, b.spamdomain.tld, ... under
#the most common identifier - the registered domain - finally.

def getRegisteredDomain(signingDomain, treeNode_ref)

	signingDomainParts = signingDomain.split(".")

	result = findRegisteredDomain(treeNode_ref, signingDomainParts)

	if result == nil
		# this is an invalid domain name
		return nil
	end

	# assure there is at least 1 TLD in the stripped signing domain
	if result.index('.') == nil
		cnt = signingDomainParts.length
		if cnt <= 1
			return nil
		end
		return signingDomainParts[-2] + "." + signingDomainParts[-1]
	else
		return result
	end
end

# recursive helper method
def findRegisteredDomain(treeNode_ref, remainingSigningDomainParts)

	if remainingSigningDomainParts.length > 0
		sub = remainingSigningDomainParts.pop()
	else
		sub = nil
	end

	if !sub
		sub = nil
	end

	result = nil

	if treeNode_ref.has_key?('!')
		return '#'
	elsif treeNode_ref.has_key?(sub)
		result = findRegisteredDomain(treeNode_ref[sub], remainingSigningDomainParts)
	elsif treeNode_ref.has_key?('*')
		result = findRegisteredDomain(treeNode_ref['*'], remainingSigningDomainParts)
	else
		return sub
	end

	if result == '#'
		return sub
	elsif result != nil && result.length > 0
		return result + "." + sub
	end
	return nil
end

