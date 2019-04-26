package main

import (
        "fmt"
        "os"
        "sync"
        "sync/atomic"

        "github.com/aws/aws-sdk-go/aws"
        "github.com/aws/aws-sdk-go/aws/awserr"
        "github.com/aws/aws-sdk-go/aws/session"
        "github.com/aws/aws-sdk-go/service/s3"
        "github.com/jessevdk/go-flags"
)

var wg sync.WaitGroup
var count int32

func listObjects(jobs chan<- string, svc *s3.S3, bucket string) {
        defer wg.Done()
        input := &s3.ListObjectsV2Input{
                Bucket:  aws.String(bucket),
                MaxKeys: aws.Int64(1000),
        }

        result, err := svc.ListObjectsV2(input)

        if err != nil {
                if awsErr, ok := err.(awserr.Error); ok {
                        switch awsErr.Code() {
                        case s3.ErrCodeNoSuchBucket:
                                fmt.Println(s3.ErrCodeNoSuchBucket, awsErr.Error())
                        default:
                                fmt.Println(awsErr.Error())
                        }
                } else {
                        // Print the error, cast err to awserr.Error to get the Code and
                        // Message from an error.
                        fmt.Println(err.Error())
                }
                return
        }

        for _, object := range result.Contents {
                jobs <- *object.Key
        }

        token := result.NextContinuationToken

        for token != nil {
                result, _ := svc.ListObjectsV2(&s3.ListObjectsV2Input{
                        Bucket:            aws.String(bucket),
                        MaxKeys:           aws.Int64(1000),
                        ContinuationToken: token,
                })

                if err != nil {
                        if awsErr, ok := err.(awserr.Error); ok {
                                switch awsErr.Code() {
                                case s3.ErrCodeNoSuchBucket:
                                        fmt.Println(s3.ErrCodeNoSuchBucket, awsErr.Error())
                                default:
                                        fmt.Println(awsErr.Error())
                                }
                        } else {
                                // Print the error, cast err to awserr.Error to get the Code and
                                // Message from an error.
                                fmt.Println(err.Error())
                        }
                        return
                }

                token = result.NextContinuationToken

                for _, object := range result.Contents {
                        jobs <- *object.Key
                }
        }

        close(jobs)
}

func worker(jobs <-chan string, results chan<- string, svc *s3.S3, bucket string, fixFlag bool) {
        defer wg.Done()

        for j := range jobs {
                input := &s3.GetObjectAclInput{
                        Bucket: aws.String(bucket),
                        Key:    aws.String(j),
                }

                result, err := svc.GetObjectAcl(input)

                if err != nil {
                        if awsErr, ok := err.(awserr.Error); ok {
                                switch awsErr.Code() {
                                case s3.ErrCodeNoSuchKey:
                                        fmt.Println(s3.ErrCodeNoSuchKey, awsErr.Error())
                                default:
                                        fmt.Println(awsErr.Error())
                                }
                        } else {
                                // Print the error, cast err to awserr.Error to get the Code and Message from an error.
                                fmt.Println(err.Error())
                        }
                        continue
                }



                for _, grant := range result.Grants {
                        //fmt.Println(*grant.Grantee.Type)
                        fmt.Println(*grant.Grantee.ID)

                        //if *grant.Grantee.Type == "Group" && *grant.Grantee.URI == "http://acs.amazonaws.com/groups/global/AllUsers" {
                        if *grant.Grantee.Type == "CanonicalUser" {
                        //if *grant.Grantee.Type == "Group" {
                        results <- j + "    ,    Permission: " + *grant.Permission
                            //if *grant.Permission == "READ" {
                            //    fmt.Println(*grant.Permission)
                            //} else if *grant.Permission == "READ_ACP" {
                                //fmt.Println(*grant.Permission)
                            }
                            //fmt.Println("length of result.Grants is ", len(result.Grants))
                            //fmt.Println("results.Grants contents is ", result.Grants)
                            //fmt.Println(*grant.Permission)

                            if fixFlag {
                                fix(svc, bucket, j)
                            }
                }

                atomic.AddInt32(&count, 1)
        }
}

func fix(svc *s3.S3, bucket string, object string) {
        fmt.Println("Fixing object ", object)
        input := &s3.PutObjectAclInput{
                ACL:    aws.String("bucket-owner-full-control"),
                Bucket: aws.String(bucket),
                Key:    aws.String(object),
        }

        _, err := svc.PutObjectAcl(input)
        if err != nil {
                if aerr, ok := err.(awserr.Error); ok {
                        switch aerr.Code() {
                        case s3.ErrCodeNoSuchKey:
                                fmt.Println(s3.ErrCodeNoSuchKey, aerr.Error())
                        default:
                                fmt.Println(aerr.Error())
                        }
                } else {
                        // Print the error, cast err to awserr.Error to get the Code and
                        // Message from an error.
                        fmt.Println(err.Error())
                }
        }
}


func main() {
        // Parse arguments
        var opts struct {
                Profile string `long:"profile" description:"AWS profile."`
                Region  string `long:"region" description:"AWS region of the S3 bucket."`
                Bucket  string `long:"bucket" description:"S3 bucket."`
                Workers int    `long:"workers" description:"Number of worker goroutines to use." default:"25"`
                Fix     bool   `long:"fix" description:"Remove public read access."`
        }

        parser := flags.NewParser(&opts, flags.Default)
        _, err := parser.Parse()

        // We have to exit manually if -h or --help is passed.
        if err != nil {
                flagError := err.(*flags.Error)

                if flagError.Type == flags.ErrHelp {
                        os.Exit(0)
                } else {
                        fmt.Fprintln(os.Stderr, err)
                }
        }

        // Set up S3 API.
        sessionOptions := session.Options{}

        if opts.Profile != "" {
                sessionOptions.Profile = opts.Profile
        }

        if opts.Region != "" {
                sessionOptions.Config = aws.Config{Region: aws.String(opts.Region)}
        }
        sessionOptions.SharedConfigState = session.SharedConfigEnable

        sesh := session.Must(session.NewSessionWithOptions(sessionOptions))
        svc := s3.New(sesh)

        /* In order to use our pool of workers we need to send them work and collect their results. We make two channels
         * for this. 5,000 elements is arbitrary. */
        jobs := make(chan string, 5000)
        results := make(chan string, 5000)

        // This starts up the workers, initially blocked because there are no jobs yet.
        for w := 1; w <= opts.Workers; w++ {
                wg.Add(1)
                go worker(jobs, results, svc, opts.Bucket, opts.Fix)
        }

        go func() {
                /* We don't need to defer wg.Done() here or use wg.Add(1) because this loop already blocks on the the results channel.
                 * That is, if we use a wg.Wait(), we hang because we're waiting for the printWorker goroutine to finish, but the goroutine
                 * is waiting for the channel to be closed. */
                for result := range results {
                        //fmt.Println("length of results is ", len(results))
                        //if len(results) != 0 {
                            fmt.Println("bucket/prefix: ", opts.Bucket + "/" + result)
                            fmt.Println("-----------------------------")
                        //}
                }
        }()

        wg.Add(1)
        go listObjects(jobs, svc, opts.Bucket)

        // Wait for all senders to finish before closing the results channel so we don't panic
        wg.Wait()
        close(results)
}
