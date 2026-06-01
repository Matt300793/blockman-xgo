from flask_sqlalchemy import SQLAlchemy

db = SQLAlchemy()

def init(app):
    with app.app_context():
        db.init_app(app)
        db.create_all()
    return db

class User(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    username = db.Column(db.String(80), unique=True, nullable=False)
    email = db.Column(db.String(120), unique=True, nullable=False)

    def __repr__(self):
        return '<User %r>' % self.username
