
sub handler {
	# my ($r, $q) = shift;
	my ($sec, $min, $hour, $mday, $mon, $year, $wday, $yday, $isdst)
		= localtime(time);
	$mon++;
	$year += 1900;
	$wday = 7 if $wday == 0;
	$yday++;

	return {
		year => $year,
		month => $mon,
		day => $mday,
		week_day => $wday,
		year_day => $yday,
		hour => $hour,
		minute => $min,
		second => $sec,
		dst => $isdst,
		};
}
