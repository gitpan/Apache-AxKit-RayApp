
sub handler {
	my ($r, $q) = @_;
	return {
		'!title' => 'Search application result',
		'searchid' => 'patt',
		'results' => [
			[ 364, 'adelton' ],
			[ 8234, 'kron' ],
			[ 923, 'Mirek' ],
			],
	};
}

1;

