from flask import render_template, url_for, flash, redirect, request, Blueprint
from aula import app, conn, bcrypt
from aula.forms import MessageSendForm, MessageSearchForm
from aula.models import select_Users, search_Users, get_user_messages, send_message_to, find_user_groups
from flask_login import login_required, current_user
import fnmatch


Message = Blueprint('Message', __name__)



@Message.route("/")
@Message.route("/home")
def home():
    return render_template('home.html')

    
@Message.route("/about")
def about():
    return render_template('about.html', title='About')



    
@Message.route("/messages", methods=['GET', 'POST'])
def message():

    if not current_user.is_authenticated:
        flash('Please Login.','danger')
        return redirect(url_for('Login.login'))

    user_messages = get_user_messages(current_user.get_key()) 
    if user_messages == None:
        user_messages = ()


    form = MessageSearchForm()
    if request.method == 'POST':
        if form.submitUsers.data:
            return send_message_Users(form,user_messages)

        if form.submitGroups.data:
            return send_message_Groups(user_messages)
        
        if request.form.get('submit'):

            recipients = request.form.get('recipients')
            # TODO: create list of recipients.
            message = request.form.get('message')
            subject = request.form.get('subject')
            isSensitive = request.form.get('isSensitive')
            sender = current_user.get_key()

            if request.form.get('isGroup'):
                recipients = request.form.get('recipients')
                # TODO: Create a list of group member id's
                # model.find_group_member

            final_message = [recipients, subject, isSensitive, message]
            send_message_to(final_message,sender)

            flash('Message Sent.','success')
            redirect(url_for('Message.message'))
            

    return render_template('messages-search.html', title='Messages', form=form, messages=user_messages)

def send_message_Users(recipient_form,user_messages):

    if not current_user.is_authenticated:
        flash('Please Login.','danger')
        return redirect(url_for('Login.login'))

    form = MessageSendForm()
  
    results = []
    search_string = recipient_form.recipients.data
    
    if search_string != '':
        results = search_Users(search_string)
        # Remove current user from search results
        results = [i for i in results if i[1] != current_user.name.lower()]

    if not results:
        flash('No results found!')
        return redirect("http://localhost:5000/home")
    else:
        form.recipients.choices = results
        return render_template('messages_send.html', results=results, form=form, messages=user_messages)

        
def send_message_Groups(user_messages):

    if not current_user.is_authenticated:
        flash('Please Login.','danger')
        return redirect(url_for('Login.login'))

    form = MessageSendForm(isGroup="True")
    
    groups = find_user_groups(current_user.get_key())
        
    if not groups:
        flash('No results found!')
        return redirect('/')
    else:
        results = ( (grp.id, grp.name) for grp in groups)
        form.recipients.choices = results
        return render_template('messages_send.html', results=results, form=form, messages=user_messages)