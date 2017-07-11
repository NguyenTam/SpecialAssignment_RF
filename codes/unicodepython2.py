# -*- coding: utf-8 -*-
import csv
import unicodecsv

def append_row_to_csv(filename,row):
    filehandler = open(filename, 'a')
    csv_writer = unicodecsv.writer(filehandler,delimiter="|")
    csv_writer.writerow(row)
    filehandler.close()

