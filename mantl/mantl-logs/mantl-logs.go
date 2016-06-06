package main

import (
	"archive/tar"
	"bufio"
	"log"
	"os"
)

func bundleLogFile(tarball *tar.Writer, filepath string) error {

	log.Printf("archiving %s\n", filepath)

	logfile, err := os.Open(filepath)
	if err != nil {
		return err
	}
	defer logfile.Close()

	info, err := logfile.Stat()
	if err != nil {
		return err
	}
	hdr, err := tar.FileInfoHeader(info, info.Name())
	if err != nil {
		return err
	}

	if err := tarball.WriteHeader(hdr); err != nil {
		return err
	}

	scanner := bufio.NewScanner(logfile)
	scanner.Split(bufio.ScanBytes)
	for scanner.Scan() {
		if _, err := tarball.Write(scanner.Bytes()); err != nil {
			return err
		}
	}
	return nil

}

func main() {

	bundle, err := os.Create("bundle.tar")
	if err != nil {
		log.Fatalln(err)
	}
	defer bundle.Close()

	tarball := tar.NewWriter(bundle)

	logfiles, err := os.Open(".logfiles")
	if err != nil {
		log.Fatalln(err)
	}
	defer logfiles.Close()

	scanner := bufio.NewScanner(logfiles)
	for scanner.Scan() {
		if err := bundleLogFile(tarball, scanner.Text()); err != nil {
			log.Fatalln(err)
		}
	}

	if err := tarball.Close(); err != nil {
		log.Fatalln(err)
	}
}
