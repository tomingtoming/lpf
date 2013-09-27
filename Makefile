all:
	ghc -O3 -threaded -with-rtsopts="-N" lpf.hs
