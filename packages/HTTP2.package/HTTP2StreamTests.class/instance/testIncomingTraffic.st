as yet unclassified
testIncomingTraffic
	| stream response headerFrame streamManager header dataFrame headerBlock continuationFrame data sem |
	sem := Semaphore new.
	streamManager := HTTP2StreamManager new.
	stream := HTTP2Stream new: 5 for: HTTP2Request new onReceiveDo: [:resp| response := resp. sem signal] streamManager: streamManager.
	header := (HTTP2Header newInContext: (HTTP2HPACKIndexTable newWith: 1000))
		add: ':method'->'GET';
		add: ':scheme'->'http';
		add: ':path' ->'/';
		add: 'authority'->'www.example.com';
		yourself.
	headerBlock := header encode.
	headerFrame := (HTTP2HeadersFrame new)
		payload: (headerBlock first: 10);
		streamIdentifier: 5;
		yourself.
	continuationFrame := (HTTP2ContinuationFrame new)
		payload: (headerBlock copyFrom: 11 to: headerBlock size);
		streamIdentifier: 5;
		flagEndHeaders: 1;
		yourself.
	data := 'some Data'.
	dataFrame := (HTTP2DataFrame new)
		payload: data;
		streamIdentifier: 5;
		flagEndStream: 1;
		yourself.
	headerFrame receiveOnStream: stream.
	continuationFrame receiveOnStream: stream.
	dataFrame receiveOnStream: stream.
	sem wait.
	self assert: response data equals: data asByteArray.
	self assert: response header equals: header.
	self assert: stream state class equals: HTTP2HalfClosedRemoteState.