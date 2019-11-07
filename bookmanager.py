import os
import sys

from flask import Flask
from flask import redirect
from flask import render_template
from flask import request

from flask_sqlalchemy import SQLAlchemy

project_dir = os.path.dirname(os.path.abspath(__file__))
# mysql+pymysql://user:password@host/dbname
if os.environ.get('DATABASE_URI'):
    database_uri = os.environ['DATABASE_URI']
elif os.environ.get('DATABASE_HOST'):
    dbname = os.environ['DATABASE_NAME']
    dbhost = os.environ.get('DATABASE_HOST')
    dbtype = os.environ.get('DATABASE_TYPE')
    dbuser = os.environ.get('DATABASE_USER')
    dbpassword = os.environ('DATABASE_PASSWORD')
    if 'mysql' in dbtype and (not dbname or not dbuser or not dbpassword):
        sys.exit(1)

    database_uri = f"{dbtype}://{dbuser}:{dbpassword}@{dbhost}/{dbname}"
else:
    database_uri = "sqlite:///{}".format(os.path.join(project_dir, "bookdatabase.db"))

app = Flask(__name__)
app.config["SQLALCHEMY_DATABASE_URI"] = database_uri

db = SQLAlchemy(app)

listen_address = os.environ.get('LISTEN_ADDRESS', 'localhost')
listen_port = os.environ.get('LISTEN_PORT', '5000')

class Book(db.Model):
    title = db.Column(db.String(80), unique=True, nullable=False, primary_key=True)

    def __repr__(self):
        return "<Title: {}>".format(self.title)

@app.route('/', methods=["GET", "POST"])
def home():
    books = None
    if request.form:
        try:
            book = Book(title=request.form.get("title"))
            db.session.add(book)
            db.session.commit()
        except Exception as e:
            print("Failed to add book")
            print(e)
    books = Book.query.all()
    return render_template("home.html", books=books)

@app.route("/update", methods=["POST"])
def update():
    try:
        newtitle = request.form.get("newtitle")
        oldtitle = request.form.get("oldtitle")
        book = Book.query.filter_by(title=oldtitle).first()
        book.title = newtitle
        db.session.commit()
    except Exception as e:
        print("Couldn't update book title")
        print(e)
    return redirect("/")

@app.route("/delete", methods=["POST"])
def delete():
    title = request.form.get("title")
    book = Book.query.filter_by(title=title).first()
    db.session.delete(book)
    db.session.commit()
    return redirect("/")


if __name__ == "__main__":
    app.run(host=listen_address, port=listen_port, debug=True)
