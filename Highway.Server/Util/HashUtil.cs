﻿using System.Security.Cryptography;
using System.Text;

namespace Highway.Server.Util;

public static class HashUtil
{
    /// <summary>
    /// Returns the hash for a given string.
    /// </summary>
    /// <param name="input">String to hash.</param>
    /// <returns>Result of the hash.</returns>
    public static string GetHash(string input)
    {
        input = input.Replace("\r", "");
        return BitConverter.ToString(SHA256.HashData(Encoding.UTF8.GetBytes(input))).Replace("-", "").ToLower();
    }
}