package EMMakePatcher;

use Exporter 'import';

use File::Find;
use File::Spec;
use Cwd;

@EXPORT = qw (patch);

sub patchMakeFile {
	my ($fileName, $emscripten, $etc, $endian_check, $strgen, $settings_gen) = @_;

	$endian_check = File::Spec->abs2rel($endian_check, getcwd);
	$strgen = File::Spec->abs2rel($strgen, getcwd);

	print "Patching Makefile '$fileName'\n";

	open(M, "<$fileName") or die "cannot open <$fileName: $!";
	my @makes = <M>;
	foreach (@makes) {
		#$_ =~ s|(^SRC_OBJS_DIR.*)/debug|$1/emscripten|g;
		#$_ =~ s|\$\(Q\)\$\(CXX_BUILD\) \$\(CFLAGS_BUILD\) \$\(CXXFLAGS_BUILD\) \$< -o \$@|cp $endian_check endian_check|;
		#$_ =~ s|(\$\(Q\))\./\$\(STRGEN\)( -s \$\(LANG_DIR\) -d table)|$1$strgen$2|;

		#$_ =~ s|^STRGEN.*|STRGEN = $strgen|;
		#$_ =~ s|^ENDIAN_CHECK.*|ENDIAN_CHECK = $endian_check|;

		if ($_ =~ m|^\$\(ENDIAN_CHECK\):|) {
			$_ = <<"ENDIAN_CHECK";
\$(ENDIAN_CHECK):
	cp $endian_check endian_check

OBSOLETE_ENDIAN_CHECK:
ENDIAN_CHECK
		}

		if ($_ =~ m|^\$\(STRGEN\)|) {
			$_ = <<"STRGEN";
\$(STRGEN):
	cp $strgen strgen

OBSOLETE_STRGEN:
STRGEN
		}

		if ($_ =~ m|^\$\(SETTINGSGEN\)|) {
			$_ = <<"SETTINGSGEN";
\$(SETTINGSGEN):
	cp $settings_gen settings_gen

OBSOLETE_SETTINGSGEN:
SETTINGSGEN
		}

#O2
#-s PRECISE_I64_MATH=0 - break code
#-O2 -s DOUBLE_MODE=0 -s CORRECT_OVERFLOWS=0 -s CORRECT_ROUNDINGS=0

		$_ =~ s|^TTD.*|TTD            = openttd.js|;
		$_ =~ s|-lSDL||g;
		$_ =~ s|-lpthread||g;
		$_ =~ s|-I/usr/include/SDL|-I$emscripten/system/include/SDL|;
		$_ =~ s|^STRIP.*||;
		$_ =~ s|(^LIBS.*=).*|$1 --pre-js $etc/pre.js --preload-file /home/caiiiycuk/play-ttd/etc/preload|;

		$_ =~ s|video/sdl_v.o|video/sdl_v_patched.o|;
		$_ =~ s|video/sdl_v.cpp|video/sdl_v_patched.cpp|;

		$_ =~ s|gfxinit.o|gfxinit_patched.o|;
		$_ =~ s|gfxinit.cpp|gfxinit_patched.cpp|;

		$_ =~ s|music/extmidi.o|music/em_midi.o|;
		$_ =~ s|music/extmidi.cpp|music/em_midi.cpp|;

		$_ =~ s|-lstdc++||g;
		$_ =~ s|-lc||g;
		$_ =~ s|-L/usr/lib/i386-linux-gnu||g;
	}

	close(M);
	open(M, ">$fileName") or die "cannot open >$fileName: $!";
	print M join('', @makes);
	close(M);
}

sub patch {
	my $target = shift;
	my @params = @_;

	find(sub {
		patchMakeFile( getcwd() . "/$_", @params ) if (m/^Makefile$/);
	}, $target);
}

1;