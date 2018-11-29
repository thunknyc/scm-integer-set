#!/bin/sh

cd `dirname $0`
snow-chibi --noimage package \
	   --test=thunknyc/integer-set-test.scm \
	   thunknyc/integer-set.sld
