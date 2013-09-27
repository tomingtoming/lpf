import Network (withSocketsDo)
import Data.Conduit (($$))
import Data.Conduit.Network
import qualified Data.ByteString.Char8 as C8
import Control.Concurrent.Async (race_)
import System.Environment (getArgs)

main :: IO ()
main = withSocketsDo $ do
  (localPort:remoteHost:remotePort:_) <- getArgs
  let
    srvConf = serverSettings (read localPort) HostAny
    cliConf = clientSettings (read remotePort) (C8.pack remoteHost)
    cliApp  = \cli -> runTCPClient cliConf (srvApp cli)
    srvApp cli = \srv -> do
      putStrLn $ "Start:" ++ (show $ appSockAddr cli)
      (appSource cli $$ appSink srv) `race_` (appSource srv $$ appSink cli)
      putStrLn $ "End  :" ++ (show $ appSockAddr cli)
  runTCPServer srvConf cliApp
