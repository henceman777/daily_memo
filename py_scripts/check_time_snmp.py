#!/usr/bin/env python2.7
#-*- coding: UTF-8 -*-
# Copyright (C) Faurecia <http://www.faurecia.com/>
#
# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the "Software"),
# to deal in the Software without restriction, including without limitation
# the rights to use, copy, modify, merge, publish, distribute, sublicense,
# and/or sell copies of the Software, and to permit persons to whom the
# Software is furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included
# in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
# OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
# IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM,
# DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
# TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE
# OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

"""
Name : check_snmp_time_sync.py
Usage : Check time sync between windows host and time server
        alerts if time difference in specified ranges.
Update : 2018/07/03
Author : JIN Max, max.jin-ext@faurecia.com, DURVILLE Guillaume
Reviewers : RAFATI Saeed, DURVILLE Guillaume, FRANK Michael
Version : 1.0

"""

import logging
import traceback
from monitoring.nagios.plugin import NagiosPluginSNMP
from datetime import datetime
import ntplib
import pytz

logger = logging.getLogger("plugin.default")

class PluginGet_SysTime(NagiosPluginSNMP):
    def define_plugin_arguments(self):
        """define the plugin's arguments type and format."""
        super(PluginGet_SysTime, self).define_plugin_arguments()
        self.required_args.add_argument('-w',
                                        dest="warning",
                                        type=int,
                                        help="Warning threshold in seconds (int)",
                                        default=30,
                                        required=True)
        self.required_args.add_argument('-c',
                                        dest="critical",
                                        type=int,
                                        help="Critical threshold in seconds (int)",
                                        default=60,
                                        required=True)
        self.required_args.add_argument('-ts',
                                        dest="timesource",
                                        type=str,
                                        help="The time source to use to get the time through ntp",
                                        default="timesource.ww.corp",
                                        required=False)
        self.required_args.add_argument('-tz',
                                        dest="client_timezone",
                                        type=str,
                                        choices=pytz.all_timezones,
                                        metavar='',
                                        default="Europe/Paris",
                                        help="Select a timezone for the target host from the timezone list. Use -tz * to print the list of all time zones",
                                        required=False)

    def verify_plugin_arguments(self):
        """"verify plugin arguments, rise exceptions if they are not legit."""
        super(PluginGet_SysTime, self).verify_plugin_arguments()
        if self.options.warning > self.options.critical:
            self.unknown('Warning threshold cannot be higher than critical !')


    def check_ntp_time(self, ts):
        """
        Gets time from time server.

        Details :
        The time server is always UTC.
        UTC is specified because the datetime object requires it to be aware.
        Aware objects are objects TZ sensitive.

        Returns:
            ntp_datetime_utc (datetime object): Time server UTC time

        Raises:
            Exception
            ==> When ntp time fetching or processing error
        """
        try:
            ntp_client = ntplib.NTPClient()
            # Original NTP system timestamp
            ntp_timestamp_naive = ntp_client.request(ts).orig_time
            #get it directly from timestamp to UTC, it needs a time zone anyways
            ntp_datetime_utc = datetime.fromtimestamp(ntp_timestamp_naive, pytz.UTC)
            logger.debug("NTP time in UTC: %s" % ntp_datetime_utc)
            return ntp_datetime_utc
        except Exception as e:
            logger.debug("Exception during NTP time querying. %s" % str(e))
            self.shortoutput = "Exception during NTP time querying. Traceback attached!"
            self.longoutput = traceback.format_exc().splitlines()
            self.unknown(self.output())

    def check_sys_time(self, tz):
        """
        Gets Snmpquery time from target host

        Details:
        This time is timezone and DST sensitive.
        It's normalized then converted to UTC.

        The return pattern from snmp is such :

        - Linux
        |yyyy|mm|dd|hh|mm|ss|decisec| +- |TZ  |
        |07e2|05|12|10|2a|33|  07   |002b|0200|

        - Windows
        |yyyy|mm|dd|hh|mm|ss|decisec|
        |07e2|05|12|10|2a|33|  07   |

        It's a hex value that has to be cast first to int.
        Note : Timezone information (fields "+- | TZ") is not present for a windows host

        The TZ section is not reliable and hence not used.
        Instead, reliance is on the arg given in the CLI.

        Returns:
            sys_datetime_utc   (datetime object): Host UTC time
            sys_datetime_local (datetime object): Host lcoal time

        Raises:
            An Exception.
            ==> When system time fetch/calculation error.
        """
        oids = {'sys_time': '1.3.6.1.2.1.25.1.2.0'}
        given_timezone = pytz.timezone(tz)

        #-----------------------------------------------------------
        # SNMP query here
        try:
            snmpquery = self.snmp.get(oids)
        except Exception as e:
            logger.debug("Exception during SNMP connect. %s" % str(e))
            self.shortoutput = "Exception during SNMP connect. Traceback attached!"
            self.longoutput = traceback.format_exc().splitlines()
            self.unknown(self.output())

        #-----------------------------------------------------------
        # deal with the SNMP query result here
        try:
            # based on successed excution of snmpquery, with str() and sliceing we could have a 16 character length long string
            # 0x07e20619072c15002b0200  :Linux SNMP result.
            # 0x07e20619060c1607        :Windows SNMP result.
            t = str(snmpquery['sys_time'])[2:18]
            logger.debug("The hex value is %s" %t)
            # Each portion of the result is cast to int from hex
            sys_datetime_naive = datetime(
                        year=int(t[0:4], 16),
                        month=int(t[4:6], 16),
                        day=int(t[6:8], 16),
                        hour=int(t[8:10], 16),
                        minute=int(t[10:12], 16),
                        second=int(t[12:14], 16),
                        microsecond=int(t[14:], 16) * 100000
                        )
            sys_datetime_local = given_timezone.normalize(given_timezone.localize(sys_datetime_naive))
            sys_datetime_utc = sys_datetime_local.astimezone(pytz.utc)
            logger.debug('Host time: %s' % sys_datetime_local)
            logger.debug('Host time in UTC: %s' % sys_datetime_utc)
            return sys_datetime_utc, sys_datetime_local
        except Exception as e:
            logger.debug("Exception during client time process. %s" % str(e))
            self.shortoutput = "Exception during client time process. Traceback attached!"
            self.longoutput = traceback.format_exc().splitlines()
            self.unknown(self.output())

def main():
    #-----------------------------------------------------------
    #Initializing default variables
    plugin = PluginGet_SysTime(version="1.0", description="Check windows host time synchronization.")
    status = None
    #-----------------------------------------------------------
    #Fetch & process ntp time
    ntp_datetime = plugin.check_ntp_time(plugin.options.timesource)

    #Fetch & process system time (utc)
    sys_datetime, sys_datetime_local = plugin.check_sys_time(plugin.options.client_timezone)

    #------------------------------------------------------------
    #Time comparison, abs([timedelta]) is practicable here
    datetime_diff = abs(ntp_datetime - sys_datetime)

    #Rounding the time diff to two point precision.
    datetime_diff_seconds = round(datetime_diff.total_seconds(), 2)

    # status judgement, allows the case of "crit=warn"
    if datetime_diff_seconds < plugin.options.warning:
        status = plugin.ok
    elif  datetime_diff_seconds > plugin.options.critical:
        status = plugin.critical
    else:
        status = plugin.warning

    #------------------------------------------------------
    #Output processing
    # shortouput
    plugin.shortoutput = "Time difference is %s seconds." % datetime_diff_seconds

    # perfdata output
    plugin.perfdata.append("diff=%s;%s;%s;" % (datetime_diff_seconds,
                                                 plugin.options.warning,
                                                 plugin.options.critical))

    # longoutput of plugin, cutting off the microsecond display
    utcfmt = '%Y-%m-%d %H:%M:%S %Z%z'
    localfmt = '%Y-%m-%d %H:%M:%S %Z (UTC%z)'
    plugin.longoutput.append("---------------------------------------------------------------------")
    plugin.longoutput.append("NTP Time  : %s" % ntp_datetime.strftime(utcfmt))
    plugin.longoutput.append("---------------------------------------------------------------------")
    plugin.longoutput.append("Host Time : %s" % sys_datetime.strftime(utcfmt))
    plugin.longoutput.append("Host Local Time (%s): %s" % (plugin.options.client_timezone,
                                                           sys_datetime_local.strftime(localfmt)))
    plugin.longoutput.append("---------------------------------------------------------------------")
    plugin.longoutput.append("Time difference in seconds : %s" % datetime_diff_seconds)

    #------------------------------------------------------
    #Exit routine
    if status:
        status(plugin.output(long_output_limit=None))
    else:
        self.shortoutput = "Unexpected plugin behavior ! Traceback attached. Please investigate in debug mode."
        self.longoutput = traceback.format_exc().splitlines()
        self.unknown(self.output(long_output_limit=None))

if __name__ == "__main__":
    main()

