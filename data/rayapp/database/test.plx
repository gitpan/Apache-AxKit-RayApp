
sub handler {
	my ($r, $q, $dbh) = @_;

	my $user_id = $q->param('user_id');
	if (defined $user_id) {
		my ($login, $password) = $dbh->selectrow_array(q!
			select login, password from test_users where id = ?
		!, {}, $user_id);
		return {
			'!title' => "User $login",
			'user_id' => $user_id,
			'login' => $login,
			'password' => $password,
		}
	}

	my $users = $dbh->selectall_arrayref(q!
		select id, login from test_users order by login
	!);

	return {
		'!title' => 'List of users',
		'users' => $users,
	};
}

1;

