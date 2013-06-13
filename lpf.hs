import System.IO
import System.Environment
import Control.Concurrent
import Network
import qualified Data.ByteString as Bs

main :: IO ()
main = withSocketsDo $ do
  (lp:rh:rp:_) <- getArgs
  socket <- listenOn $ PortNumber $ fromInteger $ read lp
  mainLoop socket rh $ PortNumber $ fromInteger $ read rp

mainLoop :: Socket -> String -> PortID -> IO ()
mainLoop socket hostname port = do
  (lh, ch, cp) <- accept socket
  putStrLn $ "Accept: " ++ ch ++ ":" ++ (show cp)
  rh <- connectTo hostname port
  _ <- forkIO $ hCopy lh rh
  _ <- forkIO $ hCopy rh lh
  mainLoop socket hostname port

hCopy :: Handle -> Handle -> IO ()
hCopy from to = do
  eof <- hIsEOF from
  if(eof)
  then return ()
  else Bs.hGetSome from (1024*256) >>= Bs.hPut to >> hFlush to >> hCopy from to
