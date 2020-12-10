from os import environ

from mongogrant.config import Config
from mongogrant.server import Server, check, path, seed

server = Server(Config(check=check, path=path, seed=seed()))
with open(environ["MONGO_INITDB_ROOT_PASSWORD_FILE"]) as f:
    root_pwd = f.read().strip()

with open(environ["MGSERVER_PASSWORD_FILE"]) as f:
    mgserver_pwd = f.read().strip()


server.set_admin_client("mongo", "root", root_pwd)
client = server.admin_client("mongo")
command = (
    "updateUser"
    if len(client.mongogrant.command("usersInfo", "mgserver")["users"])
    else "createUser"
)
client.mongogrant.command(command, "mgserver", pwd=mgserver_pwd, roles=["readWrite"])
server.set_mgdb(f"mongodb://mgserver:{mgserver_pwd}@mongo/mongogrant")
