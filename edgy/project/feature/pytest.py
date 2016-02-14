# coding: utf-8

from __future__ import absolute_import

import os

from . import Feature


class PytestFeature(Feature):
    def configure(self):
        self.dispatcher.add_listener('edgy.project.on_start', self.on_start, priority=-50)
        self.dispatcher.add_listener('edgy.project.feature.make.on_generate',
                                     self.on_make_generate, priority=-50)

    def on_make_generate(self, event):
        makefile = event.makefile
        makefile['PYTEST_OPTIONS'] = '--capture=no --cov={path} --cov-report html'.format(
            path=event.package_name.replace('.', os.sep)
        )
        makefile.add_target('test', '''
            $(VIRTUALENV_PATH)/bin/py.test $(PYTEST_OPTIONS) tests
        ''', deps=('install',), phony=True)

    def on_start(self, event):
        tests_dir = os.path.join('tests', *event.setup['name'].split('.'))
        if not os.path.exists(tests_dir):
            os.makedirs(tests_dir)

        tests_init_file = os.path.join(tests_dir, '__init__.py')

        if not os.path.exists(tests_init_file):
            self.render_file(tests_init_file, 'python/package_init.py.j2', {'is_namespace': False})

__feature__ = PytestFeature