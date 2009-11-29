/**
 * TRANSITA (temp name)
 * URL: http://transita.net/
 * License: GPLv3
 * 
 * gtfs.sql
 * 
 * This schema is pretty much a straightforward MySQL version of the gtfs spec.
 * Because we will probably import and mix multiple gtfs datasets, I added the
 * gtfs_dataset table to help keep things organized. All of the ids used within
 * a dataset are dataset-unique, so knowing where data comes from is important.
 * 
 * @author Christopher Johnson
 */

CREATE TABLE gtfs_dataset (
    gtfs_dataset_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(40),
    created DATETIME
);

CREATE TABLE gtfs_agency (
    gtfs_agency_id INT PRIMARY KEY AUTO_INCREMENT,
    gtfs_dataset_id INT,
    
    agency_id VARCHAR(40),          /* Optional. Datasets with a single agency do not require an id. */
    agency_name VARCHAR(255),       /* Required. The full name of the transit agency. */
    agency_url VARCHAR(255),        /* Required. The URL of the transit agency. */
    agency_timezone VARCHAR(40),    /* Required. The timezone where the transit agency is located. http://en.wikipedia.org/wiki/List_of_tz_zones */
    agency_lang CHAR(2),            /* Optional. A two-letter ISO 639-1 code for the primary language used by this transit agency. http://www.loc.gov/standards/iso639-2/php/code_list.php */
    agency_phone VARCHAR(20),       /* Optional. The agency_phone field contains a single voice telephone number for the specified agency. */
    
    FOREIGN KEY (gtfs_dataset_id) REFERENCES gtfs_dataset (gtfs_dataset_id)
);


CREATE TABLE gtfs_stop (
    gtfs_stop_id INT PRIMARY KEY AUTO_INCREMENT,
    gtfs_dataset_id INT,
    
    stop_id VARCHAR(40),        /* Required. Contains an ID that uniquely identifies a stop or station. */
    stop_code VARCHAR(40),      /* Optional. Contains short text or a number that uniquely identifies the stop for passengers. */
    stop_name VARCHAR(255),     /* Required. Contains the name of a stop or station. */
    stop_desc TEXT,             /* Optional. Contains a description of a stop. */
    stop_lat FLOAT,             /* Required. Contains the latitude of a stop or station. */
    stop_lon FLOAT,             /* Required. Contains the longitude of a stop or station. */
    zone_id VARCHAR(40),        /* Optional. Defines the fare zone for a stop ID. */
    stop_url VARCHAR(255),      /* Optional. Contains the URL of a web page about a particular stop. */
    location_type INT,          /* Optional. (see spec) */
    
    FOREIGN KEY (gtfs_dataset_id) REFERENCES gtfs_dataset (gtfs_dataset_id)
);


/**
 * colors are six-character hexadecimal numbers
 */
CREATE TABLE gtfs_route (
    gtfs_route_id INT PRIMARY KEY AUTO_INCREMENT,
    gtfs_dataset_id INT,
    
    route_id VARCHAR(40),           /* Required. The route_id field contains an ID that uniquely identifies a route. */
    agency_id VARCHAR(40),          /* Optional. */
    route_short_name VARCHAR(40),   /* Required. Contains the short name of a route. */
    route_long_name VARCHAR(255),   /* Required. Contains the full name of a route. */
    route_desc TEXT,                /* Optional. Contains a description of a route. */
    route_type INT,                 /* Required. Describes the type of transportation used on a route. */
    route_url VARCHAR(255),         /* Optional. Contains the URL of a web page about that particular route. */
    route_color CHAR(6),            /* Optional. In systems that have colors assigned to routes, the route_color field defines a color that corresponds to a route. */
    route_text_color CHAR(6),       /* Optional. Can be used to specify a legible color to use for text drawn against a background of route_color. */
    
    FOREIGN KEY (gtfs_dataset_id) REFERENCES gtfs_dataset (gtfs_dataset_id)
);


CREATE TABLE gtfs_trip (
    gtfs_trip_id INT PRIMARY KEY AUTO_INCREMENT,
    gtfs_dataset_id INT,
    
    route_id VARCHAR(40),           /* Required. The route_id field contains an ID that uniquely identifies a route. */
    service_id VARCHAR(40),         /* Required. Contains an ID that uniquely identifies a set of dates when service is available for one or more routes. */
    trip_id VARCHAR(40),            /* Required. Contains an ID that identifies a trip. */
    trip_headsign VARCHAR(255),     /* Optional. Contains the text that appears on a sign that identifies the trip's destination to passengers. */
    trip_short_name VARCHAR(255),   /* Optional. Contains the text that appears in schedules and sign boards to identify the trip to passengers. */
    direction_id INT,               /* Optional. Contains a binary value that indicates the direction of travel for a trip. */
    block_id VARCHAR(40),           /* Optional. Identifies the block to which the trip belongs. */
    shape_id VARCHAR(40),           /* Optional. Contains an ID that defines a shape for the trip. */
    
    FOREIGN KEY (gtfs_dataset_id) REFERENCES gtfs_dataset (gtfs_dataset_id)
);

CREATE TABLE gtfs_stop_time (
    gtfs_stop_time_id INT PRIMARY KEY AUTO_INCREMENT,
    gtfs_dataset_id INT,
    
    trip_id VARCHAR(40),                /* Required. The trip_id field contains an ID that identifies a trip. */
    arrival_time TIME,                  /* Required. The arrival_time specifies the arrival time at a specific stop for a specific trip on a route. */
    departure_time TIME,                /* Required. The departure_time specifies the departure time from a specific stop for a specific trip on a route. */
    stop_id VARCHAR(40),                /* Required. The stop_id field contains an ID that uniquely identifies a stop. */
    stop_sequence INT,                  /* Required. The stop_sequence field identifies the order of the stops for a particular trip. */
    stop_headsign INT,                  /* Optional. The stop_headsign field contains the text that appears on a sign that identifies the trip's destination to passengers. */
    pickup_type INT,                    /* Optional. The pickup_type field indicates whether passengers are picked up at a stop as part of the normal schedule or whether a pickup at the stop is not available. */
    drop_off_type INT,                  /* Optional. The drop_off_type field indicates whether passengers are dropped off at a stop as part of the normal schedule or whether a drop off at the stop is not available. */
    shape_dist_traveled VARCHAR(40),    /* Optional. When used in the stop_times.txt file, the shape_dist_traveled field positions a stop as a distance from the first shape point. */
    
    FOREIGN KEY (gtfs_dataset_id) REFERENCES gtfs_dataset (gtfs_dataset_id)
);


CREATE TABLE gtfs_calendar (
    gtfs_calendar_id INT PRIMARY KEY AUTO_INCREMENT,
    gtfs_dataset_id INT,
    
    service_id VARCHAR(40),     /* Required. The service_id contains an ID that uniquely identifies a set of dates when service is available for one or more routes. */
    monday BOOLEAN,             /* Required. The monday field contains a binary value that indicates whether the service is valid for all Mondays. */
    tuesday BOOLEAN,            /* Required. The tuesday field contains a binary value that indicates whether the service is valid for all Tuesdays. */
    wednesday BOOLEAN,          /* Required. The wednesday field contains a binary value that indicates whether the service is valid for all Wednesdays. */
    thursday BOOLEAN,           /* Required. The thursday field contains a binary value that indicates whether the service is valid for all Thursdays. */
    friday BOOLEAN,             /* Required. The friday field contains a binary value that indicates whether the service is valid for all Fridays. */
    saturday BOOLEAN,           /* Required. The saturday field contains a binary value that indicates whether the service is valid for all Saturdays. */
    sunday BOOLEAN,             /* Required. The sunday field contains a binary value that indicates whether the service is valid for all Sundays. */
    start_date DATETIME,        /* Required. The start_date field contains the start date for the service. */
    end_date DATETIME,          /* Required. The end_date field contains the end date for the service. */
    
    FOREIGN KEY (gtfs_dataset_id) REFERENCES gtfs_dataset (gtfs_dataset_id)
);


CREATE TABLE gtfs_calendar_date (
    gtfs_calendar_date_id INT PRIMARY KEY AUTO_INCREMENT,
    gtfs_dataset_id INT,
    
    service_id VARCHAR(40),     /* Required. Contains an ID that uniquely identifies a set of dates when a service exception is available for one or more routes. */
    date DATETIME,              /* Required. Specifies a particular date when service availability is different than the norm. */
    exception_type INT,         /* Required. Indicates whether service is available on the date specified in the date field. */
    
    FOREIGN KEY (gtfs_dataset_id) REFERENCES gtfs_dataset (gtfs_dataset_id)
);

CREATE TABLE gtfs_fare_attribute (
    gtfs_fare_attribute_id INT PRIMARY KEY AUTO_INCREMENT,
    gtfs_dataset_id INT,
    
    fare_id VARCHAR(40),        /* Required. The fare_id field contains an ID that uniquely identifies a fare class. */
    price DECIMAL(10,2),        /* Required. The price field contains the fare price, in the unit specified by currency_type. */
    currency_type CHAR(3),      /* Required. The currency_type field defines the currency used to pay the fare. http://www.iso.org/iso/en/prods-services/popstds/currencycodeslist.html */
    payment_method INT,         /* Required. The payment_method field indicates when the fare must be paid. */
    transfers INT,              /* Required. The transfers field specifies the number of transfers permitted on this fare. */
    transfer_duration INT,      /* Optional. The transfer_duration field specifies the length of time in seconds before a transfer expires. */
    
    FOREIGN KEY (gtfs_dataset_id) REFERENCES gtfs_dataset (gtfs_dataset_id)
);

CREATE TABLE gtfs_fare_rule (
    gtfs_fare_rule INT PRIMARY KEY AUTO_INCREMENT,
    gtfs_dataset_id INT,
    
    fare_id VARCHAR(40),            /* Required. The fare_id field contains an ID that uniquely identifies a fare class. */
    route_id VARCHAR(40),           /* Optional. The route_id field associates the fare ID with a route. */
    origin_id VARCHAR(40),          /* Optional. The origin_id field associates the fare ID with an origin zone ID. */
    destination_id VARCHAR(40),     /* Optional. The destination_id field associates the fare ID with a destination zone ID. */
    contains_id VARCHAR(40),        /* Optional. The contains_id field associates the fare ID with a zone ID, referenced from the stops.txt file. */
    
    FOREIGN KEY (gtfs_dataset_id) REFERENCES gtfs_dataset (gtfs_dataset_id)
);

CREATE TABLE gtfs_shape (
    gtfs_shape_id INT PRIMARY KEY AUTO_INCREMENT,
    gtfs_dataset_id INT,
    
    shape_id VARCHAR(40),           /* Required. The shape_id field contains an ID that uniquely identifies a shape. */
    shape_pt_lat FLOAT,             /* Required. The shape_pt_lat field associates a shape point's latitude with a shape ID. */
    shape_pt_lon FLOAT,             /* Required. The shape_pt_lon field associates a shape point's longitude with a shape ID. */
    shape_pt_sequence INT,          /* Required. The shape_pt_sequence field associates the latitude and longitude of a shape point with its sequence order along the shape. */
    shape_dist_traveled FLOAT,      /* Optional. When used in the shapes.txt file, the shape_dist_traveled field positions a shape point as a distance traveled along a shape from the first shape point. */
    
    FOREIGN KEY (gtfs_dataset_id) REFERENCES gtfs_dataset (gtfs_dataset_id)
);

CREATE TABLE gtfs_frequency (
    gtfs_frequency_id INT PRIMARY KEY AUTO_INCREMENT,
    gtfs_dataset_id INT,
    
    trip_id VARCHAR(40),    /* Required. The trip_id contains an ID that identifies a trip on which the specified frequency of service applies. */
    start_time TIME,        /* Required. The start_time field specifies the time at which service begins with the specified frequency. */
    end_time TIME,          /* Required. The end_time field indicates the time at which service changes to a different frequency (or ceases) at the first stop in the trip. */
    headway_secs INT,       /* Required. The headway_secs field indicates the time between departures from the same stop (headway) for this trip type, during the time interval specified by start_time and end_time. */
    
    FOREIGN KEY (gtfs_dataset_id) REFERENCES gtfs_dataset (gtfs_dataset_id)
);

CREATE TABLE gtfs_transfer (
    gtfs_transfer_id INT PRIMARY KEY AUTO_INCREMENT,
    gtfs_dataset_id INT,
    
    from_stop_id VARCHAR(40),   /* Required. The from_stop_id field contains a stop ID that identifies a stop or station where a connection between routes begins. */
    to_stop_id VARCHAR(40),     /* Required. The to_stop_id field contains a stop ID that identifies a stop or station where a connection between routes ends. */
    transfer_type INT,          /* Required. The transfer_type field specifies the type of connection for the specified (from_stop_id, to_stop_id) pair. */
    min_transfer_time INT,      /* Optional. When a connection between routes requires an amount of time between arrival and departure (transfer_type=2), the min_transfer_time field defines the amount of time that must be available in an itinerary to permit a transfer between routes at these stops. */
    
    FOREIGN KEY (gtfs_dataset_id) REFERENCES gtfs_dataset (gtfs_dataset_id)
);
