package main

import (
	"bufio"
	"crypto/tls"
	"fmt"
	"log"
	"net"
	"os"
)

func check(e error) {
	if e != nil {
		panic(e)
	}
}

func main() {

	file, err := os.Open("websites.txt")

	check(err)

	defer file.Close()

	scanner := bufio.NewScanner(file)

	for scanner.Scan() {

		url := scanner.Text()

		if _, err := net.LookupHost(url); err != nil {
			errFmt := fmt.Errorf("url lookup failed: %v", err)
			fmt.Println(errFmt)
			continue
		}

		result, err := extractCertificateInfo(url)

		if err != nil {
			fmt.Printf("Error for %s: %v\n", url, err)
			continue
		}

		for _, res := range result {
			fmt.Println(res)
		}
	}
}

func extractCertificateInfo(url string) ([]CertificateInfo, error) {

	certList := []CertificateInfo{}

	conf := &tls.Config{
		InsecureSkipVerify: true,
	}

	conn, err := tls.Dial("tcp", url+":443", conf)
	if err != nil {
		log.Println("Error in Dial", err)
		return certList, err
	}
	defer conn.Close()

	certs := conn.ConnectionState().PeerCertificates

	for _, cert := range certs {

		// skip CA certificates
		if cert.IsCA {
			continue
		}

		entry := CertificateInfo{
			Address:        url,
			ExpirationDate: cert.NotAfter.Format("2006-January-02"),
		}

		certList = append(certList, entry)
	}

	return certList, nil
}

type CertificateInfo struct {
	Address        string
	ExpirationDate string
}
