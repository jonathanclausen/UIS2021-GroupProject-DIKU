from flask import render_template, url_for, flash, redirect, request, Blueprint
from aula import app, conn, bcrypt
from aula.forms import UserLoginForm
from flask_login import login_user, current_user, logout_user, login_required
from aula.models import select_Users

Login = Blueprint('Login', __name__)

posts = [{}]


@Login.route("/")
@Login.route("/home")
def home():
    return render_template('home.html', posts=posts)

    
@Login.route("/about")
def about():
    return render_template('about.html', title='About')


@Login.route("/login", methods=['GET', 'POST'])
def login():
    if current_user.is_authenticated:
        return redirect(url_for('Login.home'))
    form = UserLoginForm()
    if form.validate_on_submit():
        user = select_Users(form.id.data)
        if user != None and bcrypt.check_password_hash(user[3], form.password.data):
            login_user(user, remember=form.remember.data)
            flash('Login successful.','success')
            next_page = request.args.get('next')
            return redirect(next_page) if next_page else redirect(url_for('Login.home'))
        else:
            flash('Login Unsuccessful. Please check identifier and password', 'danger')
    return render_template('login.html', title='Login', form=form)


@Login.route("/logout")
def logout():
    logout_user()
    return redirect(url_for('Login.home'))


@Login.route("/account")
@login_required
def account():
    return render_template('account.html', title='Account')
    