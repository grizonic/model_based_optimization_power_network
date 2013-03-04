from xml.etree import cElementTree as ET
from sys import argv
import codecs
import os
from dateutil.parser import parse
from datetime import datetime

def get_files(filter_type, filter_value, filter2_type, filter2_value, start, end):
    files_list = []
    files_in_interval = []
    if start is not None:
        for file in os.listdir('XML/'):
            dt = datetime.strptime(file.split('_')[0], "%d%m%Y")
            if dt is not None and dt >= start:
                files_in_interval.append(file)
        if end is not None:
            for file in files_in_interval:
                dt = datetime.strptime(file.split('_')[0], "%d%m%Y")
                if dt is not None and dt > end:
                    files_in_interval.remove(file)
    elif end is not None:
        for file in os.listdir('XML/'):
            dt = datetime.strptime(file.split('_')[0], "%d%m%Y")
            if dt is not None and dt <= end:
                files_in_interval.append(file)
    if files_in_interval == [] and start is None and end is None:
        files_in_interval = os.listdir('XML/')
    if filter_value is not None and filter_type is not None and filter2_value is not None and filter2_type is not None:
        for file in files_in_interval:
            if '.xml' in file and filter_value+filter_type in file and filter2_value+filter2_type in file:
                files_list.append(file)
    elif filter_value is not None and filter_type is not None:
        for file in files_in_interval:
            if '.xml' in file and filter_value+filter_type in file:
                files_list.append(file)
    elif filter2_value is not None and filter2_type is not None:
        for file in files_in_interval:
            if '.xml' in file and filter2_value+filter2_type in file:
                files_list.append(file)
    else:
        for file in files_in_interval:
            if '.xml' in file:
                files_list.append(file)
    return files_list

def avg_exclude_aliens(values):
    """
    Calculates the average of an array, only regards the values in between the +/- 15% from the AVG
    """
    values_sum = 0
    excluded_stuff = False
    for value in values:
        values_sum += value
    avg = values_sum/float(len(values))
    print 'Average is %s' % avg
    for value in values:
        if value > avg*1.15 or value < avg*0.85:
            values.pop(values.index(value))
            print 'Excluded - %s' % value
            excluded_stuff = True
    if excluded_stuff is True:
        avg = avg_exclude_aliens(values)
    return avg

def calculate(file_to_process, skip, mode='calc'):
    try:
        a = open('XML/' + file_to_process, 'r')
        xml = a.read()
    except:
        return None
    data_dict = {}
    headers_dict = {}
    graph = {}
    elements = ET.XML(xml)
    CT = elements.find('CT')
    data = CT.find('MeasData')
    grid = data.find('Grid')
    headers = grid.find('Headers')
    for j, (key, i) in enumerate(headers.attrib.items()):
        headers_dict[key] = i
    for i in grid.findall('R'):
        for j, (key, attrib) in enumerate(i.attrib.items()):
            if 'C00' in key:
                try:
                    data_dict[key].append(attrib)
                except:
                    data_dict[key] = [attrib]
    tg_sum = 0
    tg_num = 0
    for key in data_dict.keys():
        if 'U rms' in headers_dict[key]:
            voltage_key = key
    voltages = data_dict[voltage_key]
    for key in data_dict.keys():
        if 'DF' in headers_dict[key]:
            tan_key = key
    tangents = data_dict[tan_key]
    for j in range(len(tangents)):
        if skip == 'first' and voltages[j] > voltages[j+1]:
            pass
        else:
            skip = None
            if mode == 'calc':
                tg_num += 1
                tg_sum += float(tangents[j])
            elif mode == 'graph':
                rounded_voltage = int(round(float(voltages[j].split(' ')[0])/50.0)*50)
                graph[rounded_voltage] = tangents[j] 
    if mode == 'calc':    
        return (tg_sum/(float(tg_num)))
    elif mode == 'graph':
        return graph
    else:
        return None
        
    """
    for key, da in data_dict.items():
        
        if 'DF' in headers_dict[key]:
            for tg in da:
                tangents += float(tg)
                tg_num += 1
    """

def create_csv(file_to_process, output_directory):
    try:
        a = open('XML/' + file_to_process, 'r')
        xml = a.read()
        b = codecs.open(output_directory + file_to_process.replace('xml', 'csv'), encoding='utf-8', mode='w+')
    except:
        print '\nCould not open file %s, check permissions!\n' % file_to_process
        print file_to_process
        quit()

    elements = ET.XML(xml)
    CT = elements.find('CT')
    data = CT.find('MeasData')
    grid = data.find('Grid')
    headers = grid.find('Headers')
    csv_headers = ''
    number_of_headers = len(headers.attrib)
    for j, (key, i) in enumerate(headers.attrib.items()):
        csv_headers += '%s' % i
        if j < number_of_headers - 1:
            csv_headers += ', '
        else:
            csv_headers += '\n'
    b.write(csv_headers)
    for i in grid.findall('R'):
        rs = ''
        for j, (key, attrib) in enumerate(i.attrib.items()):
            if key in headers.keys():
                if 'Cp' in headers.attrib[key]:
                    rs += '%s' % str(float(attrib.split(' ')[0])*1e-12)
                elif 'Ix' in headers.attrib[key]:
                    rs += '%s' % str(float(attrib.split(' ')[0])*1e-6)
                elif headers.attrib[key] != 'Time':
                    rs += '%s' % attrib.split(' ')[0]
                else:
                    rs += '%s' % attrib
                if j < number_of_headers - 1:
                    rs += ', '
        b.write(rs + '\n')
    b.close()
    return True

def main():
    tangents = 0
    tg_num = 0
    first_row = 0
    valid = True
    all_files = False
    filter_value = None
    filter_type = None
    filter2_value = None
    filter2_type = None
    mode = None
    start = None
    end = None
    skip = None
    csv_directory = 'CSV/'
    
    if '--directory' in argv:
        start_index = argv.index('--directory')
        if len(argv) > start_index+1:
            csv_directory = argv[start_index+1]

    if '--start' in argv:
        start_index = argv.index('--start')
        if len(argv) > start_index+1:
            try:
                start = datetime.strptime(argv[start_index+1], "%d%m%Y")
            except:
                print 'Couldn\'t parse the start date'

    if '--end' in argv:
        end_index = argv.index('--end')
        if len(argv) > end_index+1:
            try:
                end = datetime.strptime(argv[end_index+1], "%d%m%Y")
            except:
                print 'Couldn\'t parse the end date'
    
    if '--filter' in argv:
        filter_index = argv.index('--filter')
        if len(argv) > filter_index+1:
            filter_type = argv[filter_index+1]
            if 'kHz' in filter_type:
                filter_value = filter_type.split('kHz')[0]
                if filter_value not in ['NA', '0', '5']:
                    valid = False
                filter_type = 'kHz'
            elif 'C' in filter_type:
                filter_value = filter_type.split('C')[0]
                if filter_value not in ['NA', '40']:
                    valid = False
                filter_type = 'C'
            else:
                print 'No/wrong filter specified'
                quit()
            if valid is False:
                print 'Filter out of range'
                quit()
        else:
            print 'No/wrong filter specified'
            quit()
    
    print '\nUsing filter:\nType -> %s\nValue -> %s\n' % (filter_type, filter_value)
    
    if '--filter2' in argv:
        filter_index = argv.index('--filter2')
        if len(argv) > filter_index+1:
            filter2_type = argv[filter_index+1]
            if 'kHz' in filter2_type:
                filter2_value = filter2_type.split('kHz')[0]
                if filter2_value not in ['NA', '0', '5']:
                    valid = False
                filter2_type = 'kHz'
            elif 'C' in filter2_type:
                filter2_value = filter2_type.split('C')[0]
                if filter2_value not in ['NA', '40']:
                    valid = False
                filter2_type = 'C'
            else:
                print 'No/wrong filter specified'
                quit()
            if valid is False or filter2_type == filter_type:
                print 'Filter out of range or filter == filter2'
                quit()
        else:
            print 'No/wrong filter specified'
            quit()
    
    print '\nUsing filter2:\nType -> %s\nValue -> %s\n' % (filter2_type, filter2_value)

    if '--all' in argv:
        all_files = True
    elif '--file' in argv:
        file_index = argv.index('--file')
        if len(argv) > file_index+1 and '.xml' in argv[file_index+1]:
            all_files = False
            file_to_process = argv[file_index+1].split('/')[1]
            print '\nProcessing file -> %s\n' % file_to_process
    else:
        print 'Warning: no file specified, all *.xml files in the directory will be processed\n'
        all_files = True

    if '--skip' in argv:
        skip_index = argv.index('--skip')
        if len(argv) > skip_index+1 and argv[skip_index+1] in ['first']:
            skip = argv[skip_index+1]
        else:
            print '\nSomething went wrong while specifying the skip type\n'
            quit()
    
    
    if '--mode' in argv:
        mode_index = argv.index('--mode')
        if len(argv) > mode_index+1 and argv[mode_index+1] in ['csv', 'calc', 'graph', 'daily_csv']:
            if argv[mode_index+1] == 'csv':
                mode = 'csv'
            elif argv[mode_index+1] == 'calc':
                mode = 'calc'
            elif argv[mode_index+1] == 'graph':
                mode = 'graph'
            elif argv[mode_index+1] == 'daily_csv':
                mode = 'daily_csv'
            else:
                print '\nSomething went wrong while specifying the mode\n'
                quit()
        else:
            print '\nSomething went wrong while specifying the mode\n'
            quit()

    else:
        print '\nWarning: mode not specified. csv will be taken as the default mode'
        mode = 'csv'
    
    if mode is not None:
        if all_files is True:
            files_list = get_files(filter_type, filter_value, filter2_type, filter2_value, start, end)
            if files_list == []:
                print '\n No files fit the filter\n'
                quit()
        else:
            files_list = [file_to_process]
        if mode == 'csv':
            print '\n'
            for in_file in files_list:
                success = create_csv(in_file, csv_directory)
                if success is True:
                    print 'Converting %s was successful!' % in_file
                else:
                    print '\nSomething went wrong with the conversion of file %s\n' % in_file
            print '\n'
        elif mode == 'daily_csv':
            print '\n'
            out_file = open(csv_directory + filter_value + filter_type + '_' + filter2_value + filter2_type + '.csv', 'w')
            out_file.write('Date, AVG(tan delta)')
            out_file.close()
            values = []
            for in_file in files_list:
                value = calculate(in_file, skip)
                values.append(value)
                date = str(datetime.strptime(in_file.split('_')[0], "%d%m%Y").date())
                out_file = open(csv_directory + filter_value + filter_type + '_' + filter2_value + filter2_type + '.csv', 'a')
                out_file.write('\n%s, %s' % (date, value))
                out_file.close()
                print 'Calculating %s was successful!' % in_file
            sum_value = 0
            for value in values:
                sum_value += value
            out_file = open(csv_directory + filter_value + filter_type + '_' + filter2_value + filter2_type + '.csv', 'a')
            out_file.write('\n%s, %s' % ('AVG', (sum_value/float(len(values)))))
            out_file.close()
            
                

            print '\n'
        elif mode == 'graph':
            final_graph = {}
            all_values_graph = {}
            print '\n'
            for in_file in files_list:
                individual_graph = calculate(in_file, skip, mode)
                if individual_graph is not None:
                    print 'Calculating %s was successful!' % in_file
                    for key, value in individual_graph.items():
                        try:
                            all_values_graph[key].append(value)
                        except:
                            all_values_graph[key] = [value]
                else:
                    print '\nSomething went wrong with the calculation of file %s\n' % in_file
            for key, values in all_values_graph.items():
                values_sum = 0
                for value in values:
                    values_sum += float(value)
                final_graph[key] = values_sum/(float(len(values)))
            print '\nFinal Graph -> %s\n' % str(final_graph)
            
        elif mode == 'calc':
            print '\n'
            values = 0
            for in_file in files_list:
                value = calculate(in_file, skip)
                if value is not None:
                    print 'Calculating %s was successful!' % in_file
                    values += float(value)
                else:
                    print '\nSomething went wrong with the calculation of file %s\n' % in_file
            print '\nAverage is -> %f\n' % (values/(float(len(files_list))))

main()
