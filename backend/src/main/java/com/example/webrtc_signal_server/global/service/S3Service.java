package com.example.webrtc_signal_server.global.service;

import com.amazonaws.services.s3.AmazonS3Client;
import com.amazonaws.services.s3.model.S3Object;
import com.amazonaws.services.s3.model.S3ObjectInputStream;
import com.amazonaws.services.s3.model.S3ObjectSummary;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.nio.charset.StandardCharsets;
import java.util.Comparator;
import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class S3Service {

    private final AmazonS3Client amazonS3Client;

    @Value("${cloud.aws.s3.bucket}")
    private String bucket;

    public String findLatestRecapFile(String roomName) {
        String prefix = "Summarize/" + roomName + "_";
        
        List<S3ObjectSummary> summaries = amazonS3Client.listObjects(bucket, prefix).getObjectSummaries();
        
        if (summaries.isEmpty()) {
            throw new IllegalArgumentException("No recap file found for room: " + roomName);
        }

        // 가장 최근에 수정된 파일 찾기
        S3ObjectSummary latestFile = summaries.stream()
                .max(Comparator.comparing(S3ObjectSummary::getLastModified))
                .orElseThrow(() -> new IllegalArgumentException("No recap file found for room: " + roomName));

        return latestFile.getKey();
    }

    public String getFileContent(String key) {
        S3Object s3Object = amazonS3Client.getObject(bucket, key);
        S3ObjectInputStream inputStream = s3Object.getObjectContent();

        try (BufferedReader reader = new BufferedReader(new InputStreamReader(inputStream, StandardCharsets.UTF_8))) {
            return reader.lines().collect(Collectors.joining("\n"));
        } catch (IOException e) {
            throw new RuntimeException("Failed to read file from S3", e);
        }
    }
}
