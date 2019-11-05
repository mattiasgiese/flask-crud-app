FROM python:3
LABEL Maintainer 'Tux Pinguin <training@b1-systems.de>'
ADD . /app
WORKDIR /app
RUN pip3 install -r requirements.txt
CMD python3 bookmanager.py
