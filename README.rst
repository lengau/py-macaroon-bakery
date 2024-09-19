===============
Macaroon Bakery
===============

A Python library for working with macaroons.


Installation
------------
The easiest way to install macaroonbakery is via pip::

    $ pip install macaroonbakery

macaroonbakery was developed around pymacaroons. On ubuntu, you
can get libsodium from a ppa::

	$ sudo add-apt-repository ppa:yellow/ppa -y
	$ apt-get install libsodium13

Usage
-----
Interacting with a protected url, you can use the BakeryAuth provided to deal
with the macaroon bakery

    >>> from macaroonbakery import httpbakery
    >>> import requests
    >>> jar = requests.cookies.RequestsCookieJar()
    >>> client = httpbakery.Client(cookies=jar)
    >>> client.request(
    ...     "GET", "https://api.staging.charmhub.io/v1/tokens/whoami"
    ... ).json()


You can use any cookie storage you'd like so next subsequent calls the macaroon
saved in the cookie jar will be directly used and will not require
any other authentication (for example, cookielib.FileCookieJar).
