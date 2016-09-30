# talks-app

An application for serving up a web-UI over talks stored in an S3 bucket.

# Requirements
 * ruby 2

# Configuration

## Local
Copy `.env.example` to `.env`, and `config.toml.example` to `config.toml`, replacing the data as instructed in the files.

## S3
### Permissions
A dedicated bucket is required.
The user configured in the `.env` requires permission to list and get the bucket and it's contents.
An example policy:
```
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "s3:Get*",
                "s3:List*"
            ],
            "Resource": [
                "arn:aws:s3:::talks-app",
                "arn:aws:s3:::talks-app/*"                
            ]
        }
    ]
}
```

### Data structure
Each talk has it's own folder at the top level of the bucket. The name of the folder forms the id of the talk that is used in urls.

Inside the talk folder should be a file called `talk.toml`.
This is a [toml](https://github.com/toml-lang/toml) file, the structure of which is described below.

Alongside the `talk.toml` file can be arbitrary files to present as files for download.
They must not be in nested directories.
For them to be presented, they must be listed in the `talk.toml` file.

### talk.toml
```
# Details of  the talk as a whole go at the top level
title = "Jack and Jill - A tale"                                    # Title of the talk. Required
date = 2016-01-01T15:30:00Z                                         # Date of the talk, in the form yyyy-mm-ddThh:mm:ssZ. Optional
presenter = "Jack and Jill"                                         # Presenter(s) of the talk. Optional
description = "They describe their adventures going up the hill"    # Description of the talk. Renders using markdown. Optional

    # Can embed videos for the whole talk. Can have zero or more, by repeating the block below
    [[embed]]
    name = "jack-and-jill.mp4"                                      # Name of the file. Must be in the same directory. Required
    type = "video"                                                  # Type of the file. Currently only "video" supported. Required
    aspect_ratio = "16:9"                                           # Aspect ratio, of the form "w:h". Required

    # Files associated with the whole talk. Can have zero or more, by repeating the block below
    [[files]]
    name = "jack-and-jill.mp4"                                      # Name of the file. Must be in the same directory. Required    
    type = "video"                                                  # Type of the file. Can be anything, but "video", "audio" and "slides" have their own icon. Required

    
    # A talk can be broken down into sections. Can have zero or more sections, by repeating the block below
    [[section]]
    title = "Tumbling"                                              # The title of the section. Required
    presenter = "Jack"                                              # Presenter(s) of the section. Optional
    description = "Why Jack went tumbling after"                    # Description of the section. Optional

        # Embeded files associated with the section. Can have zero or more, by repeating the block below
        [[embed]]
        name = "jack.mp4"                                           # Name of the file. Must be in the same directory. Required
        type = "video"                                              # Type of the file. Currently only "video" supported. Required
        aspect_ratio = "16:9"                                       # Aspect ratio, of the form "w:h". Required

        # Files associated with the section. Can have zero or more files, by repeating the block below
        [[section.files]]
        name = "jack.pdf"                                           # Name of the file. Must be in the same directory. Required
        type = "slides"                                             # Type of the file. Can be anything, but "video", "audio" and "slides" have their own icon. Required
```
