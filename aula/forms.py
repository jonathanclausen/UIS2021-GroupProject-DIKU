from flask_wtf import FlaskForm
from wtforms import StringField, PasswordField, SubmitField, BooleanField, IntegerField, SelectMultipleField, TextAreaField
from wtforms.fields.simple import HiddenField
from wtforms.validators import DataRequired, Length, EqualTo, ValidationError

class UserLoginForm(FlaskForm):
    id = StringField('Username', validators=[DataRequired()])
    password = PasswordField('Password', validators=[DataRequired()])
    remember = BooleanField('Remember Me')
    submit = SubmitField('Login')

class AdminLoginForm(FlaskForm):
    id = IntegerField('Id', validators=[DataRequired()])
    password = PasswordField('Password', validators=[DataRequired()])
    remember = BooleanField('Remember Me')
    submit = SubmitField('Login')

class MessageSearchForm(FlaskForm):
    recipients = StringField('Vælg modtagere')
    submitUsers = SubmitField('Search for Users')
    submitGroups = SubmitField("Select from Groups")

class MessageSendForm(FlaskForm):
    choices=[('w', 'w')]
    isGroup = HiddenField("isGroup")
    recipients = SelectMultipleField('Vælg modtagere', validators=[DataRequired()],choices=choices)
    subject = StringField('Indsæt emne', validators=[DataRequired()])
    isSensitive = BooleanField('Følsom data?')
    message = TextAreaField('Indsæt besked', validators=[DataRequired()])
    submit = SubmitField('Send')

class UserSearchForm(FlaskForm):
    subject = StringField('Search', validators=[DataRequired()])
    submit = SubmitField('Search')
