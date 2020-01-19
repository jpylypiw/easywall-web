"""the app module contains all information of the Flask app"""
import os

from easywall.config import Config
from easywall.log import Log
from flask import Flask
from easywall_web.apply import apply, apply_save
from easywall_web.blacklist import blacklist, blacklist_save
from easywall_web.custom import custom, custom_save
from easywall_web.error import page_not_found
from easywall_web.index import index
from easywall_web.login import login_post, logout
from easywall_web.options import options, options_save
from easywall_web.ports import ports, ports_save
from easywall_web.whitelist import whitelist, whitelist_save


app = Flask(__name__)
CFG = Config("config/web.ini")


@app.route('/')
def index_route():
    """The function calls the corresponding function from the appropriate module"""
    return index()


@app.route('/options')
def options_route():
    """The function calls the corresponding function from the appropriate module"""
    return options()


@app.route('/options-save', methods=['POST'])
def options_save_route():
    """The function calls the corresponding function from the appropriate module"""
    return options_save()


@app.route('/blacklist')
def blacklist_route():
    """The function calls the corresponding function from the appropriate module"""
    return blacklist()


@app.route('/blacklist-save', methods=['POST'])
def blacklist_save_route():
    """The function calls the corresponding function from the appropriate module"""
    return blacklist_save()


@app.route('/whitelist')
def whitelist_route():
    """The function calls the corresponding function from the appropriate module"""
    return whitelist()


@app.route('/whitelist-save', methods=['POST'])
def whitelist_save_route():
    """The function calls the corresponding function from the appropriate module"""
    return whitelist_save()


@app.route('/ports')
def ports_route():
    """The function calls the corresponding function from the appropriate module"""
    return ports()


@app.route('/ports-save', methods=['POST'])
def ports_save_route():
    """The function calls the corresponding function from the appropriate module"""
    return ports_save()


@app.route('/custom')
def custom_route():
    """The function calls the corresponding function from the appropriate module"""
    return custom()


@app.route('/custom-save', methods=['POST'])
def custom_save_route():
    """The function calls the corresponding function from the appropriate module"""
    return custom_save()


@app.route('/apply')
def apply_route():
    """The function calls the corresponding function from the appropriate module"""
    return apply()


@app.route('/apply-save', methods=['POST'])
def apply_save_route():
    """The function calls the corresponding function from the appropriate module"""
    return apply_save()


@app.route('/login', methods=['POST'])
def login_post_route():
    """The function calls the corresponding function from the appropriate module"""
    return login_post()


@app.route("/logout")
def logout_route():
    """The function calls the corresponding function from the appropriate module"""
    return logout()


@app.errorhandler(404)
def page_not_found_route(error):
    """The function calls the corresponding function from the appropriate module"""
    return page_not_found(error)


# only debugging
if __name__ == '__main__':
    app.secret_key = os.urandom(12)
    PORT = int(CFG.get_value("WEB", "bindport"))
    HOST = CFG.get_value("WEB", "bindip")
    DEBUG = True
    app.run(HOST, PORT, DEBUG)

# production mode
if __name__ == 'uwsgi_file_app':
    app.secret_key = os.urandom(12)
