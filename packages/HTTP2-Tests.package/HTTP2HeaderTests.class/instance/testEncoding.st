testing
testEncoding
	| header indexTable encodedHeaders |
	indexTable := HTTP2HPACKIndexTable new.
	header := HTTP2HeaderTests standardHeader.
	encodedHeaders := self class encodedTestHeaders.
	self assert: (header encode: indexTable) equals: encodedHeaders first.
	header add: 'cache-control'->'no-cache'.
	self assert: (header encode: indexTable) equals: encodedHeaders second.
	header := self class testHeaders second.
	self assert: (header encode: indexTable) equals: encodedHeaders third.
	header addNeverIndexing: 'password' value: 'secret' .
	self assert: (header encode: indexTable) equals: encodedHeaders fourth.