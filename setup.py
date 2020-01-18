"""this is the setup module for easywall-web"""
from setuptools import setup


def readme():
    """include the readme as long_description"""
    with open('README.md') as handler:
        return handler.read()


setup(
    name='easywall_web',
    version='0.0.1',
    description='Easy-to-use web interface developed in Python to control the easywall core application',
    long_description=readme(),
    classifiers=[
        'Development Status :: 3 - Alpha',
        'License :: OSI Approved :: GNU General Public License v3 or later (GPLv3+)',
        'Programming Language :: Python :: 3.7',
        'Topic :: Internet :: WWW/HTTP :: WSGI :: Application',
        'Framework :: Flask'
    ],
    keywords="webinterface Flask easywall",
    url='https://github.com/jpylypiw/easywall-web',
    author='Jochen Pylypiw',
    author_email='jochen@pylypiw.com',
    license='GPL-3.0',
    packages=['easywall_web'],
    install_requires=[
        'Flask',
    ],
    dependency_links=[
        'http://github.com/jpylypiw/easywall/tarball/master#egg=easywall'
    ],
    include_package_data=True,
    zip_safe=False,
    setup_requires=[
        'pytest-runner',
    ],
    tests_require=[
        'pytest-cov',
        'pytest-pythonpath',
        'pytest'
    ]
)
