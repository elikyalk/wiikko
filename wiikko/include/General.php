<?php

    class General
    {
        public static function fetchAssocStatement($stmt)
        {
            if ($stmt->num_rows > 0) {
                $result = [];
                $md = $stmt->result_metadata();
                $params = [];
                while ($field = $md->fetch_field()) {
                    $params[] = &$result[$field->name];
                }
                call_user_func_array([$stmt, 'bind_result'], $params);
                if ($stmt->fetch()) {
                    return $result;
                }
            }

            return null;
        }

        public static function correctPassword($pw) {
            if(strlen($pw)<8 || strpos($pw, ' ') !== false) return false;
            return true;
        }

    }
