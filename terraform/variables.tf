/**
 * Copyright 2021 Google LLC
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

variable "project_id" {
  description = "Project ID to create Cloud Function"
  type        = string
}

variable "function_location" {
  description = "The location of this cloud function"
  type        = string
}

// IAM
variable "members" {
  type        = map(list(string))
  description = "Cloud Function Invoker and Developer roles for Users/SAs. Key names must be developers and/or invokers"
  default     = {}
  validation {
    condition = alltrue([
      for key in keys(var.members) : contains(["invokers", "developers"], key)
    ])
    error_message = "The supported keys are invokers and developers."
  }
}
