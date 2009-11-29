<?php
/**
 * TRANSITA (temp name)
 * URL: http://transita.net/
 * License: GPLv3
 * 
 * import.sql.php
 * 
 * This template constructs sql for importing gtfs data into a MySQL database.
 * The gtfs schema must be in place before importing data (see gtfs.sql).
 * 
 * Usage:
 * 
 *      Download a gtfs zip file and unzip it
 *      cd /unzip/directory
 *      php path/to/here/import.sql.php | mysql -uuser -ppassword database
 * 
 * @author Christopher Johnson
 */

/**
 * Analyzes a gtfs file for use in the SQL template below.
 */
class GtfsFile {
    
    /**
     * @param $file string gtfs file name
     * @param $table string corresponding database table
     * @param $fields array fields in the database table
     */
    public function __construct($file, $table, $fields) {
        $this->name = $file;
        $this->table = $table;
        $this->fields = $fields;
        $this->analyzeCSV();
    }
    
    /**
     * Read the header row of the gtfs file,
     * compare the gtfs headers to the table fields,
     * discard any headers that are not database fields,
     * and determine the type of line terminator used.
     */
    private function analyzeCSV() {
        // open file
        $handle = @fopen($this->name, 'r');
        if (!$handle) {
            log_notice('File not found '.$this->name);
            return;
        }
        
        // grab a bunch of characters from the file
        // (hopefully enough to cover the first line)
        $bunch = fread($handle, 1024);
        
        // find the end of the first line
        if (!preg_match('/\\r?\\n/', $bunch, $matches, PREG_OFFSET_CAPTURE)) {
            log_error('Error analyzing the header line of '.$file);
            return;
        }
        
        // get the gtfs headers
        $line = substr($bunch, 0, $matches[0][1]);
        // TODO: strip the BOM if present
        $this->headers = explode(',', $line);
        
        // mark headers that aren't database fields as ignore
        $discards = array();
        foreach ($this->headers as $key => $header) {
            if (!in_array($header, $this->fields)) {
                $this->headers[$key] = '@discard';
                $discards[] = $header;
            }
        }
        if (!empty($discards)) {
            log_notice('Discarding column(s) from '.$this->name.': '.implode(', ', $discards));
        }
        
        // determine the type of line terminator used
        $this->terminator = $matches[0][0] == "\r\n" ? '\\r\\n' : '\\n';
    }
    
    /**
     * Is this is a usable gtfs file?
     * @return boolean
     */
    public function usable() {
        return !empty($this->headers);
    }
}

/**
 * Writes an error message into the sql output of this template.
 * @param $message string
 */
function log_notice($message) {
    echo "SELECT '".addslashes($message)."' AS notice;\n";
}

/**
 * Writes an error message into the sql output of this template.
 * @param $message string
 */
function log_error($message) {
    echo "SELECT '".addslashes($message)."' AS error;\n";
}

// list of files to import
$files = array(
    new GtfsFile('agency.txt', 'gtfs_agency', array('agency_id', 'agency_name', 'agency_url', 'agency_timezone', 'agency_lang', 'agency_phone')),
    new GtfsFile('stops.txt',  'gtfs_stop',   array('stop_id', 'stop_code', 'stop_name', 'stop_desc', 'stop_lat', 'stop_lon', 'zone_id', 'stop_url', 'location_type', 'parent_station')),
    new GtfsFile('routes.txt', 'gtfs_route',  array('route_id', 'agency_id', 'route_short_name', 'route_long_name', 'route_desc', 'route_type', 'route_url', 'route_color', 'route_text_color')),
    new GtfsFile('trips.txt',  'gtfs_trip',   array('route_id', 'service_id', 'trip_id', 'trip_headsign', 'trip_short_name', 'direction_id', 'block_id', 'shape_id')),
    new GtfsFile('stop_times.txt', 'gtfs_stop_time', array('trip_id', 'arrival_time', 'departure_time', 'stop_id', 'stop_sequence', 'stop_headsign', 'pickup_type', 'drop_off_type', 'shape_dist_traveled')),
    new GtfsFile('calendar.txt',   'gtfs_calendar',  array('service_id', 'monday', 'tuesday', 'wednesday', 'thursday', 'friday', 'saturday', 'sunday', 'start_date', 'end_date')),
    new GtfsFile('calendar_dates.txt',  'gtfs_calendar_date',  array('service_id', 'date', 'exception_type')),
    new GtfsFile('fare_attributes.txt', 'gtfs_fare_attribute', array('fare_id', 'price', 'currency_type', 'payment_method', 'transfers', 'transfer_duration')),
    new GtfsFile('fare_rules.txt',  'gtfs_fare_rule', array('fare_id', 'route_id', 'origin_id', 'destination_id', 'contains_id')),
    new GtfsFile('shapes.txt',      'gtfs_shape',     array('shape_id', 'shape_pt_lat', 'shape_pt_lon', 'shape_pt_sequence', 'shape_dist_traveled')),
    new GtfsFile('frequencies.txt', 'gtfs_frequency', array('trip_id', 'start_time', 'end_time', 'headway_secs')),
    new GtfsFile('transfers.txt',   'gtfs_transfer',  array('from_stop_id', 'to_stop_id', 'transfer_type', 'min_transfer_time')),
);

// pull unusable files out of the list
foreach ($files as $index => $file) {
    if (!$file->usable()) {
        unset($files[$index]);
    }
}

// only continue if we have some files to import
if (empty($files)) {
    log_error('No usable gtfs files in the current directory');
    return;
}

// begin sql template
?>

/* create a new dataset and get the id */
INSERT INTO gtfs_dataset (created) VALUES (NOW());
SET @dataset_id = LAST_INSERT_ID();

<?php foreach ($files as $file): ?>
<?php log_notice('Loading gtfs data from '.$file->name) ?>

LOAD DATA LOCAL INFILE '<?php echo $file->name ?>' 
    INTO TABLE <?php echo $file->table ?> 
    CHARACTER SET 'utf8' 
    FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"' 
    LINES TERMINATED BY '<?php echo $file->terminator ?>' 
    IGNORE 1 LINES 
    (<?php echo implode(', ', $file->headers) ?>) 
    SET gtfs_dataset_id = @dataset_id;

<?php endforeach; ?>
