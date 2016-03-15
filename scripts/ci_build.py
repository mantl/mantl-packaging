#!/usr/bin/env python
import sys
import os
from os import path
from subprocess import check_call, check_output
import re

DIR = path.abspath(path.dirname(__file__))
ROOT = path.abspath(path.join(DIR, '..'))

PATH_RE = re.compile(r'\|(.+?)\| (.+)')
PATHS = dict([
    PATH_RE.match(line.strip()).groups() for line
    in open(path.join(DIR, 'paths')).readlines()
    if PATH_RE.match(line) is not None
])

if os.environ['TRAVIS_COMMIT_RANGE'] == '':
    COMMITS = os.environ['TRAVIS_COMMIT_RANGE']
    COMMIT_RANGE = COMMITS
    DIFF_COMMAND = ['git', 'diff', '--name-only', COMMITS]
else:
    COMMITS = os.environ['TRAVIS_COMMIT']
    COMMIT_RANGE = ''
    DIFF_COMMAND = ['git', 'show', '--name-only', '--pretty=format:', COMMITS]


def build(names, stream_for=None):
    print 'Building %s' % ', '.join(names)
    args = ['tools/bin/hammer', 'build', '--output=/tmp/out']
    if stream_for:
        args.append('--stream-logs-for=%s' % stream_for)

    args.extend(names)
    check_call(args)


def main(args):
    print 'Evaluating whether to build %s' % COMMITS

    if COMMIT_RANGE and 'ci: all' in check_output(['git', 'log', COMMIT_RANGE]):
        names = PATHS.keys()
    else:
        names = [
            name for (name, path)
            in PATHS.items()
            if 0 != len([
                line for line
                in check_output(DIFF_COMMAND).split()
                if line.startswith(path)
            ])
        ]

    if 'mesos' in names:
        stream_for = 'mesos'
    elif 'marathon' in names:
        stream_for = 'marathon'
    elif len(names) == 1:
        stream_for = names[0]
    else:
        stream_for = None

    if names:
        try:
            build(names, stream_for)
        except subprocess.CalledProcessError as e:
            sys.stderr.write('`%s` returned non-zero exit code %d' % (' '.join(e.cmd), e.returncode))
            return 1
    else:
        print 'nothing to build, skipping'

    return 0

if __name__ == '__main__':
    sys.exit(main(sys.argv[1:]))
