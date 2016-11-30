#!/usr/bin/env python
# -*- coding: utf-8 -*-

from __future__ import absolute_import
from __future__ import division
from __future__ import print_function
from __future__ import unicode_literals

import sys
import argparse


def parse_args():
    parser = argparse.ArgumentParser(description='PLACEHOLDER')
    parser.add_argument('-n', '--topn', type=int, required=False, default=-1)
    parser.add_argument('--switch', required=False, default=False, action='store_true')
    parser.add_argument('filename')

    if len(sys.argv)==1:
        parser.print_help()
        sys.exit(1)

    args = parser.parse_args()
    return args


def main():
    args = parse_args()
    print('topn={} switch={} filename={}'.format(args.topn, args.switch, args.filename))


if __name__ == '__main__':
    main()
