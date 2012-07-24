Module['preRun'] = function() { 
  createMusicFiles();
  SDL.defaults.copyOnLock = false;

  FS.createPath('/', 'home/caiiiycuk/play-ttd/etc/preload/save', true, true);
  FS.createPreloadedFile(
  	'/home/caiiiycuk/play-ttd/etc/preload/save', 
  	'perfomacne_test.sav', 
  	//'http://play-ttd.com/save/perfomance_test.sav', 
  	'http://localhost/perfomance_test.sav',
  	true, true);
};

//'-d', '3'
Module['arguments'] = ['-s', 'null', '-m', 'em_midi', '-x', '-c', '/home/caiiiycuk/play-ttd/etc/preload/openttd.cfg', '-r', '640x480', '-g', '/home/caiiiycuk/play-ttd/etc/preload/save/perfomacne_test.sav'];