defmodule ETitleWeb.HomeLive do
  use ETitleWeb, :live_view

  def mount(_params, _session, socket) do
    {:ok, assign(socket, mobile_menu_open: false)}
  end

  def handle_event("toggle_mobile_menu", _params, socket) do
    {:noreply, assign(socket, mobile_menu_open: !socket.assigns.mobile_menu_open)}
  end

  def handle_event("close_mobile_menu", _params, socket) do
    {:noreply, assign(socket, mobile_menu_open: false)}
  end

  def render(assigns) do
    ~H"""
    <div class="min-h-screen bg-gradient-to-b from-green-50 to-green-100">
      <!-- Navigation -->
      <nav class="bg-white shadow-lg fixed w-full top-0 z-50">
        <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div class="flex justify-between items-center h-16">
            <!-- Logo -->
            <div class="flex items-center">
              <div class="flex-shrink-0 flex items-center">
                <svg
                  class="h-6 w-6 sm:h-8 sm:w-8 text-green-600 mr-2"
                  fill="none"
                  stroke="currentColor"
                  viewBox="0 0 24 24"
                >
                  <path
                    stroke-linecap="round"
                    stroke-linejoin="round"
                    stroke-width="2"
                    d="M3 12l2-2m0 0l7-7 7 7M5 10v10a1 1 0 001 1h3m10-11l2 2m-2-2v10a1 1 0 01-1 1h-3m-6 0a1 1 0 001-1v-4a1 1 0 011-1h2a1 1 0 011 1v4a1 1 0 001 1m-6 0h6"
                  >
                  </path>
                </svg>
                <span class="text-lg sm:text-2xl font-bold text-green-800">E-Title</span>
              </div>
            </div>
            
    <!-- Desktop Navigation -->
            <div class="hidden lg:flex items-center space-x-6 xl:space-x-8">
              <a
                href="#home"
                class="text-gray-700 hover:text-green-600 px-3 py-2 rounded-md text-sm font-medium transition-colors"
              >
                Home
              </a>
              <a
                href="#about"
                class="text-gray-700 hover:text-green-600 px-3 py-2 rounded-md text-sm font-medium transition-colors"
              >
                About Us
              </a>
              <a
                href="#contact"
                class="text-gray-700 hover:text-green-600 px-3 py-2 rounded-md text-sm font-medium transition-colors"
              >
                Contact Us
              </a>
              <a
                href="#register"
                class="bg-green-600 hover:bg-green-700 text-white px-4 xl:px-6 py-2 rounded-md text-sm font-medium transition-colors"
              >
                Register
              </a>
            </div>
            
    <!-- Mobile menu button -->
            <div class="lg:hidden">
              <button
                phx-click="toggle_mobile_menu"
                data-mobile-menu-button
                class="text-gray-700 hover:text-green-600 focus:outline-none focus:text-green-600 p-2"
                aria-label="Toggle mobile menu"
              >
                <svg class="h-6 w-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path
                    stroke-linecap="round"
                    stroke-linejoin="round"
                    stroke-width="2"
                    d={
                      if @mobile_menu_open,
                        do: "M6 18L18 6M6 6l12 12",
                        else: "M4 6h16M4 12h16M4 18h16"
                    }
                  >
                  </path>
                </svg>
              </button>
            </div>
          </div>
          
    <!-- Mobile Navigation Menu -->
          <div
            data-mobile-menu
            class={[
              "lg:hidden transition-all duration-300 ease-in-out",
              if(@mobile_menu_open,
                do: "max-h-96 opacity-100",
                else: "max-h-0 opacity-0 overflow-hidden"
              )
            ]}
          >
            <div class="px-2 pt-2 pb-3 space-y-1 bg-white border-t border-gray-200">
              <a
                href="#home"
                phx-click="close_mobile_menu"
                class="block px-3 py-2 text-base font-medium text-gray-700 hover:text-green-600 hover:bg-green-50 rounded-md transition-colors"
              >
                Home
              </a>
              <a
                href="#about"
                phx-click="close_mobile_menu"
                class="block px-3 py-2 text-base font-medium text-gray-700 hover:text-green-600 hover:bg-green-50 rounded-md transition-colors"
              >
                About Us
              </a>
              <a
                href="#contact"
                phx-click="close_mobile_menu"
                class="block px-3 py-2 text-base font-medium text-gray-700 hover:text-green-600 hover:bg-green-50 rounded-md transition-colors"
              >
                Contact Us
              </a>
              <a
                href="#register"
                phx-click="close_mobile_menu"
                class="block px-3 py-2 text-base font-medium bg-green-600 text-white hover:bg-green-700 rounded-md transition-colors text-center"
              >
                Register
              </a>
            </div>
          </div>
        </div>
      </nav>
      
    <!-- Hero Section -->
      <section id="home" class="pt-20 pb-12 sm:pt-24 sm:pb-16 lg:pt-28 lg:pb-20 px-4 sm:px-6 lg:px-8">
        <div class="max-w-7xl mx-auto">
          <div class="text-center">
            <h1 class="text-3xl sm:text-4xl md:text-5xl lg:text-6xl font-bold text-gray-900 mb-4 sm:mb-6 leading-tight">
              <span class="block">Secure Land</span>
              <span class="block text-green-600">Registration</span>
              <span class="block">Made Simple</span>
            </h1>
            <p class="text-base sm:text-lg lg:text-xl text-gray-600 mb-6 sm:mb-8 max-w-3xl mx-auto leading-relaxed px-4">
              Streamline your land registration process with our digital platform.
              Secure, transparent, and efficient land title management for the modern era.
            </p>
            <div class="flex flex-col sm:flex-row gap-3 sm:gap-4 justify-center px-4">
              <button class="w-full sm:w-auto bg-green-600 hover:bg-green-700 text-white px-6 sm:px-8 py-3 sm:py-4 rounded-lg text-base sm:text-lg font-semibold transition-colors shadow-lg hover:shadow-xl">
                Register Your Land
              </button>
              <button class="w-full sm:w-auto border-2 border-green-600 text-green-600 hover:bg-green-600 hover:text-white px-6 sm:px-8 py-3 sm:py-4 rounded-lg text-base sm:text-lg font-semibold transition-colors">
                Learn More
              </button>
            </div>
          </div>
          
    <!-- Hero Features -->
          <div class="mt-12 sm:mt-16 lg:mt-20">
            <div class="bg-white rounded-lg sm:rounded-xl shadow-xl p-6 sm:p-8 lg:p-10">
              <div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-6 sm:gap-8">
                <div class="text-center">
                  <div class="bg-green-100 rounded-full w-12 h-12 sm:w-16 sm:h-16 flex items-center justify-center mx-auto mb-3 sm:mb-4">
                    <svg
                      class="w-6 h-6 sm:w-8 sm:h-8 text-green-600"
                      fill="none"
                      stroke="currentColor"
                      viewBox="0 0 24 24"
                    >
                      <path
                        stroke-linecap="round"
                        stroke-linejoin="round"
                        stroke-width="2"
                        d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z"
                      >
                      </path>
                    </svg>
                  </div>
                  <h3 class="text-base sm:text-lg font-semibold text-gray-900 mb-2">
                    Secure Registration
                  </h3>
                  <p class="text-sm sm:text-base text-gray-600 leading-relaxed">
                    Blockchain-secured land titles ensure authenticity and prevent fraud
                  </p>
                </div>

                <div class="text-center">
                  <div class="bg-green-100 rounded-full w-12 h-12 sm:w-16 sm:h-16 flex items-center justify-center mx-auto mb-3 sm:mb-4">
                    <svg
                      class="w-6 h-6 sm:w-8 sm:h-8 text-green-600"
                      fill="none"
                      stroke="currentColor"
                      viewBox="0 0 24 24"
                    >
                      <path
                        stroke-linecap="round"
                        stroke-linejoin="round"
                        stroke-width="2"
                        d="M13 10V3L4 14h7v7l9-11h-7z"
                      >
                      </path>
                    </svg>
                  </div>
                  <h3 class="text-base sm:text-lg font-semibold text-gray-900 mb-2">
                    Fast Processing
                  </h3>
                  <p class="text-sm sm:text-base text-gray-600 leading-relaxed">
                    Digital workflows reduce registration time from months to days
                  </p>
                </div>

                <div class="text-center sm:col-span-2 lg:col-span-1">
                  <div class="bg-green-100 rounded-full w-12 h-12 sm:w-16 sm:h-16 flex items-center justify-center mx-auto mb-3 sm:mb-4">
                    <svg
                      class="w-6 h-6 sm:w-8 sm:h-8 text-green-600"
                      fill="none"
                      stroke="currentColor"
                      viewBox="0 0 24 24"
                    >
                      <path
                        stroke-linecap="round"
                        stroke-linejoin="round"
                        stroke-width="2"
                        d="M8 14v3m4-3v3m4-3v3M3 21h18M3 10h18M3 7l9-4 9 4M4 10h16v11H4V10z"
                      >
                      </path>
                    </svg>
                  </div>
                  <h3 class="text-base sm:text-lg font-semibold text-gray-900 mb-2">
                    Government Approved
                  </h3>
                  <p class="text-sm sm:text-base text-gray-600 leading-relaxed">
                    Fully compliant with national land registration standards
                  </p>
                </div>
              </div>
            </div>
          </div>
        </div>
      </section>
      
    <!-- About Us Section -->
      <section id="about" class="py-12 sm:py-16 lg:py-20 bg-white">
        <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div class="text-center mb-12 sm:mb-16">
            <h2 class="text-2xl sm:text-3xl lg:text-4xl font-bold text-gray-900 mb-4">
              About E-Title
            </h2>
            <p class="text-base sm:text-lg lg:text-xl text-gray-600 max-w-3xl mx-auto leading-relaxed">
              We're revolutionizing land registration through innovative technology and streamlined processes.
            </p>
          </div>

          <div class="grid grid-cols-1 lg:grid-cols-2 gap-8 sm:gap-12 lg:gap-16 items-center">
            <div class="order-2 lg:order-1">
              <h3 class="text-xl sm:text-2xl font-bold text-gray-900 mb-4 sm:mb-6">Our Mission</h3>
              <p class="text-sm sm:text-base text-gray-600 mb-6 leading-relaxed">
                To provide a secure, transparent, and efficient digital platform for land registration
                that serves property owners, legal professionals, and government agencies.
              </p>
              <ul class="space-y-3 sm:space-y-4">
                <li class="flex items-start">
                  <svg
                    class="w-5 h-5 sm:w-6 sm:h-6 text-green-600 mr-3 mt-0.5 sm:mt-1 flex-shrink-0"
                    fill="none"
                    stroke="currentColor"
                    viewBox="0 0 24 24"
                  >
                    <path
                      stroke-linecap="round"
                      stroke-linejoin="round"
                      stroke-width="2"
                      d="M5 13l4 4L19 7"
                    >
                    </path>
                  </svg>
                  <span class="text-sm sm:text-base text-gray-700">
                    Eliminate paperwork and reduce processing time
                  </span>
                </li>
                <li class="flex items-start">
                  <svg
                    class="w-5 h-5 sm:w-6 sm:h-6 text-green-600 mr-3 mt-0.5 sm:mt-1 flex-shrink-0"
                    fill="none"
                    stroke="currentColor"
                    viewBox="0 0 24 24"
                  >
                    <path
                      stroke-linecap="round"
                      stroke-linejoin="round"
                      stroke-width="2"
                      d="M5 13l4 4L19 7"
                    >
                    </path>
                  </svg>
                  <span class="text-sm sm:text-base text-gray-700">
                    Provide secure and tamper-proof land records
                  </span>
                </li>
                <li class="flex items-start">
                  <svg
                    class="w-5 h-5 sm:w-6 sm:h-6 text-green-600 mr-3 mt-0.5 sm:mt-1 flex-shrink-0"
                    fill="none"
                    stroke="currentColor"
                    viewBox="0 0 24 24"
                  >
                    <path
                      stroke-linecap="round"
                      stroke-linejoin="round"
                      stroke-width="2"
                      d="M5 13l4 4L19 7"
                    >
                    </path>
                  </svg>
                  <span class="text-sm sm:text-base text-gray-700">
                    Enable easy access to land ownership information
                  </span>
                </li>
              </ul>
            </div>

            <div class="order-1 lg:order-2 bg-green-50 rounded-lg p-6 sm:p-8">
              <h4 class="text-lg sm:text-xl font-semibold text-gray-900 mb-4 sm:mb-6">
                Why Choose E-Title?
              </h4>
              <div class="space-y-3 sm:space-y-4">
                <div class="bg-white rounded-lg p-4 sm:p-5 shadow-sm">
                  <h5 class="font-semibold text-gray-900 mb-2 text-sm sm:text-base">
                    10+ Years Experience
                  </h5>
                  <p class="text-gray-600 text-xs sm:text-sm leading-relaxed">
                    Trusted by thousands of property owners and professionals
                  </p>
                </div>
                <div class="bg-white rounded-lg p-4 sm:p-5 shadow-sm">
                  <h5 class="font-semibold text-gray-900 mb-2 text-sm sm:text-base">99.9% Uptime</h5>
                  <p class="text-gray-600 text-xs sm:text-sm leading-relaxed">
                    Reliable platform available when you need it
                  </p>
                </div>
                <div class="bg-white rounded-lg p-4 sm:p-5 shadow-sm">
                  <h5 class="font-semibold text-gray-900 mb-2 text-sm sm:text-base">24/7 Support</h5>
                  <p class="text-gray-600 text-xs sm:text-sm leading-relaxed">
                    Expert assistance whenever you need help
                  </p>
                </div>
              </div>
            </div>
          </div>
        </div>
      </section>
      
    <!-- Contact Us Section -->
      <section id="contact" class="py-12 sm:py-16 lg:py-20 bg-gray-50">
        <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div class="text-center mb-12 sm:mb-16">
            <h2 class="text-2xl sm:text-3xl lg:text-4xl font-bold text-gray-900 mb-4">Contact Us</h2>
            <p class="text-base sm:text-lg lg:text-xl text-gray-600 max-w-3xl mx-auto leading-relaxed">
              Get in touch with our team for any questions about land registration or our services.
            </p>
          </div>

          <div class="grid grid-cols-1 lg:grid-cols-2 gap-8 sm:gap-12">
            <!-- Contact Form -->
            <div class="bg-white rounded-lg sm:rounded-xl shadow-lg p-6 sm:p-8">
              <h3 class="text-xl sm:text-2xl font-bold text-gray-900 mb-4 sm:mb-6">
                Send us a Message
              </h3>
              <form class="space-y-4 sm:space-y-6">
                <div>
                  <label for="name" class="block text-sm font-medium text-gray-700 mb-2">
                    Full Name
                  </label>
                  <input
                    type="text"
                    id="name"
                    name="name"
                    class="w-full px-3 sm:px-4 py-2 sm:py-3 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-green-500 text-sm sm:text-base"
                    required
                  />
                </div>
                <div>
                  <label for="email" class="block text-sm font-medium text-gray-700 mb-2">
                    Email Address
                  </label>
                  <input
                    type="email"
                    id="email"
                    name="email"
                    class="w-full px-3 sm:px-4 py-2 sm:py-3 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-green-500 text-sm sm:text-base"
                    required
                  />
                </div>
                <div>
                  <label for="subject" class="block text-sm font-medium text-gray-700 mb-2">
                    Subject
                  </label>
                  <input
                    type="text"
                    id="subject"
                    name="subject"
                    class="w-full px-3 sm:px-4 py-2 sm:py-3 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-green-500 text-sm sm:text-base"
                    required
                  />
                </div>
                <div>
                  <label for="message" class="block text-sm font-medium text-gray-700 mb-2">
                    Message
                  </label>
                  <textarea
                    id="message"
                    name="message"
                    rows="4"
                    class="w-full px-3 sm:px-4 py-2 sm:py-3 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-green-500 text-sm sm:text-base resize-none"
                    required
                  ></textarea>
                </div>
                <button
                  type="submit"
                  class="w-full bg-green-600 hover:bg-green-700 text-white py-3 sm:py-4 px-4 rounded-md font-semibold transition-colors text-sm sm:text-base"
                >
                  Send Message
                </button>
              </form>
            </div>
            
    <!-- Contact Information -->
            <div class="order-first lg:order-last">
              <h3 class="text-xl sm:text-2xl font-bold text-gray-900 mb-4 sm:mb-6">Get in Touch</h3>
              <div class="space-y-4 sm:space-y-6">
                <div class="flex items-start">
                  <div class="bg-green-100 rounded-full w-10 h-10 sm:w-12 sm:h-12 flex items-center justify-center mr-3 sm:mr-4 flex-shrink-0">
                    <svg
                      class="w-5 h-5 sm:w-6 sm:h-6 text-green-600"
                      fill="none"
                      stroke="currentColor"
                      viewBox="0 0 24 24"
                    >
                      <path
                        stroke-linecap="round"
                        stroke-linejoin="round"
                        stroke-width="2"
                        d="M17.657 16.657L13.414 20.9a1.998 1.998 0 01-2.827 0l-4.244-4.243a8 8 0 1111.314 0z"
                      >
                      </path>
                      <path
                        stroke-linecap="round"
                        stroke-linejoin="round"
                        stroke-width="2"
                        d="M15 11a3 3 0 11-6 0 3 3 0 016 0z"
                      >
                      </path>
                    </svg>
                  </div>
                  <div>
                    <h4 class="text-base sm:text-lg font-semibold text-gray-900 mb-1">
                      Office Address
                    </h4>
                    <p class="text-sm sm:text-base text-gray-600 leading-relaxed">
                      123 Land Registry Building<br /> Government District<br /> Nairobi, Kenya
                    </p>
                  </div>
                </div>

                <div class="flex items-start">
                  <div class="bg-green-100 rounded-full w-10 h-10 sm:w-12 sm:h-12 flex items-center justify-center mr-3 sm:mr-4 flex-shrink-0">
                    <svg
                      class="w-5 h-5 sm:w-6 sm:h-6 text-green-600"
                      fill="none"
                      stroke="currentColor"
                      viewBox="0 0 24 24"
                    >
                      <path
                        stroke-linecap="round"
                        stroke-linejoin="round"
                        stroke-width="2"
                        d="M3 5a2 2 0 012-2h3.28a1 1 0 01.948.684l1.498 4.493a1 1 0 01-.502 1.21l-2.257 1.13a11.042 11.042 0 005.516 5.516l1.13-2.257a1 1 0 011.21-.502l4.493 1.498a1 1 0 01.684.949V19a2 2 0 01-2 2h-1C9.716 21 3 14.284 3 6V5z"
                      >
                      </path>
                    </svg>
                  </div>
                  <div>
                    <h4 class="text-base sm:text-lg font-semibold text-gray-900 mb-1">
                      Phone Numbers
                    </h4>
                    <p class="text-sm sm:text-base text-gray-600 leading-relaxed">
                      <a href="tel:+254700123456" class="hover:text-green-600 transition-colors">
                        +254 700 123 456
                      </a>
                      <br />
                      <a href="tel:+254711789012" class="hover:text-green-600 transition-colors">
                        +254 711 789 012
                      </a>
                    </p>
                  </div>
                </div>

                <div class="flex items-start">
                  <div class="bg-green-100 rounded-full w-10 h-10 sm:w-12 sm:h-12 flex items-center justify-center mr-3 sm:mr-4 flex-shrink-0">
                    <svg
                      class="w-5 h-5 sm:w-6 sm:h-6 text-green-600"
                      fill="none"
                      stroke="currentColor"
                      viewBox="0 0 24 24"
                    >
                      <path
                        stroke-linecap="round"
                        stroke-linejoin="round"
                        stroke-width="2"
                        d="M3 8l7.89 5.26a2 2 0 002.22 0L21 8M5 19h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v10a2 2 0 002 2z"
                      >
                      </path>
                    </svg>
                  </div>
                  <div>
                    <h4 class="text-base sm:text-lg font-semibold text-gray-900 mb-1">Email</h4>
                    <p class="text-sm sm:text-base text-gray-600 leading-relaxed">
                      <a
                        href="mailto:info@e-title.gov.ke"
                        class="hover:text-green-600 transition-colors"
                      >
                        info@e-title.gov.ke
                      </a>
                      <br />
                      <a
                        href="mailto:support@e-title.gov.ke"
                        class="hover:text-green-600 transition-colors"
                      >
                        support@e-title.gov.ke
                      </a>
                    </p>
                  </div>
                </div>

                <div class="flex items-start">
                  <div class="bg-green-100 rounded-full w-10 h-10 sm:w-12 sm:h-12 flex items-center justify-center mr-3 sm:mr-4 flex-shrink-0">
                    <svg
                      class="w-5 h-5 sm:w-6 sm:h-6 text-green-600"
                      fill="none"
                      stroke="currentColor"
                      viewBox="0 0 24 24"
                    >
                      <path
                        stroke-linecap="round"
                        stroke-linejoin="round"
                        stroke-width="2"
                        d="M12 8v4l3 3m6-3a9 9 0 11-18 0 9 9 0 0118 0z"
                      >
                      </path>
                    </svg>
                  </div>
                  <div>
                    <h4 class="text-base sm:text-lg font-semibold text-gray-900 mb-1">
                      Office Hours
                    </h4>
                    <p class="text-sm sm:text-base text-gray-600 leading-relaxed">
                      Monday - Friday: 8:00 AM - 5:00 PM<br /> Saturday: 9:00 AM - 1:00 PM
                    </p>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>
      </section>
      
    <!-- Footer -->
      <footer class="bg-gray-900 text-white">
        <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8 sm:py-12">
          <div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-6 sm:gap-8">
            <!-- Company Info -->
            <div class="sm:col-span-2 lg:col-span-2">
              <div class="flex items-center mb-3 sm:mb-4">
                <svg
                  class="h-6 w-6 sm:h-8 sm:w-8 text-green-400 mr-2"
                  fill="none"
                  stroke="currentColor"
                  viewBox="0 0 24 24"
                >
                  <path
                    stroke-linecap="round"
                    stroke-linejoin="round"
                    stroke-width="2"
                    d="M3 12l2-2m0 0l7-7 7 7M5 10v10a1 1 0 001 1h3m10-11l2 2m-2-2v10a1 1 0 01-1 1h-3m-6 0a1 1 0 001-1v-4a1 1 0 011-1h2a1 1 0 011 1v4a1 1 0 001 1m-6 0h6"
                  >
                  </path>
                </svg>
                <span class="text-xl sm:text-2xl font-bold">E-Title</span>
              </div>
              <p class="text-sm sm:text-base text-gray-300 mb-4 sm:mb-6 max-w-md leading-relaxed">
                Transforming land registration through digital innovation. Secure, transparent,
                and efficient land title management for the modern era.
              </p>
              <div class="flex space-x-4">
                <!-- Social Media Links -->
                <a
                  href="https://facebook.com/etitle"
                  class="text-gray-300 hover:text-green-400 transition-colors p-1"
                  aria-label="Facebook"
                >
                  <svg class="w-5 h-5 sm:w-6 sm:h-6" fill="currentColor" viewBox="0 0 24 24">
                    <path d="M24 12.073c0-6.627-5.373-12-12-12s-12 5.373-12 12c0 5.99 4.388 10.954 10.125 11.854v-8.385H7.078v-3.47h3.047V9.43c0-3.007 1.792-4.669 4.533-4.669 1.312 0 2.686.235 2.686.235v2.953H15.83c-1.491 0-1.956.925-1.956 1.874v2.25h3.328l-.532 3.47h-2.796v8.385C19.612 23.027 24 18.062 24 12.073z" />
                  </svg>
                </a>
                <a
                  href="https://x.com/etitle"
                  class="text-gray-300 hover:text-green-400 transition-colors p-1"
                  aria-label="X (Twitter)"
                >
                  <svg class="w-5 h-5 sm:w-6 sm:h-6" fill="currentColor" viewBox="0 0 24 24">
                    <path d="M18.244 2.25h3.308l-7.227 8.26 8.502 11.24H16.17l-5.214-6.817L4.99 21.75H1.68l7.73-8.835L1.254 2.25H8.08l4.713 6.231zm-1.161 17.52h1.833L7.084 4.126H5.117z" />
                  </svg>
                </a>
                <a
                  href="https://linkedin.com/company/etitle"
                  class="text-gray-300 hover:text-green-400 transition-colors p-1"
                  aria-label="LinkedIn"
                >
                  <svg class="w-5 h-5 sm:w-6 sm:h-6" fill="currentColor" viewBox="0 0 24 24">
                    <path d="M20.447 20.452h-3.554v-5.569c0-1.328-.027-3.037-1.852-3.037-1.853 0-2.136 1.445-2.136 2.939v5.667H9.351V9h3.414v1.561h.046c.477-.9 1.637-1.85 3.37-1.85 3.601 0 4.267 2.37 4.267 5.455v6.286zM5.337 7.433c-1.144 0-2.063-.926-2.063-2.065 0-1.138.92-2.063 2.063-2.063 1.14 0 2.064.925 2.064 2.063 0 1.139-.925 2.065-2.064 2.065zm1.782 13.019H3.555V9h3.564v11.452zM22.225 0H1.771C.792 0 0 .774 0 1.729v20.542C0 23.227.792 24 1.771 24h20.451C23.2 24 24 23.227 24 22.271V1.729C24 .774 23.2 0 22.222 0h.003z" />
                  </svg>
                </a>
              </div>
            </div>
            
    <!-- Quick Links -->
            <div>
              <h3 class="text-base sm:text-lg font-semibold mb-3 sm:mb-4">Quick Links</h3>
              <ul class="space-y-2">
                <li>
                  <a
                    href="#home"
                    class="text-sm sm:text-base text-gray-300 hover:text-green-400 transition-colors"
                  >
                    Home
                  </a>
                </li>
                <li>
                  <a
                    href="#about"
                    class="text-sm sm:text-base text-gray-300 hover:text-green-400 transition-colors"
                  >
                    About Us
                  </a>
                </li>
                <li>
                  <a
                    href="#contact"
                    class="text-sm sm:text-base text-gray-300 hover:text-green-400 transition-colors"
                  >
                    Contact Us
                  </a>
                </li>
                <li>
                  <a
                    href="#register"
                    class="text-sm sm:text-base text-gray-300 hover:text-green-400 transition-colors"
                  >
                    Register
                  </a>
                </li>
                <li>
                  <a
                    href="/privacy"
                    class="text-sm sm:text-base text-gray-300 hover:text-green-400 transition-colors"
                  >
                    Privacy Policy
                  </a>
                </li>
                <li>
                  <a
                    href="/terms"
                    class="text-sm sm:text-base text-gray-300 hover:text-green-400 transition-colors"
                  >
                    Terms of Service
                  </a>
                </li>
              </ul>
            </div>
            
    <!-- Services -->
            <div>
              <h3 class="text-base sm:text-lg font-semibold mb-3 sm:mb-4">Services</h3>
              <ul class="space-y-2">
                <li>
                  <a
                    href="/services/registration"
                    class="text-sm sm:text-base text-gray-300 hover:text-green-400 transition-colors"
                  >
                    Land Registration
                  </a>
                </li>
                <li>
                  <a
                    href="/services/search"
                    class="text-sm sm:text-base text-gray-300 hover:text-green-400 transition-colors"
                  >
                    Title Search
                  </a>
                </li>
                <li>
                  <a
                    href="/services/transfer"
                    class="text-sm sm:text-base text-gray-300 hover:text-green-400 transition-colors"
                  >
                    Property Transfer
                  </a>
                </li>
                <li>
                  <a
                    href="/services/verification"
                    class="text-sm sm:text-base text-gray-300 hover:text-green-400 transition-colors"
                  >
                    Document Verification
                  </a>
                </li>
                <li>
                  <a
                    href="/support"
                    class="text-sm sm:text-base text-gray-300 hover:text-green-400 transition-colors"
                  >
                    Support Center
                  </a>
                </li>
              </ul>
            </div>
          </div>

          <div class="border-t border-gray-700 mt-6 sm:mt-8 pt-6 sm:pt-8 text-center">
            <p class="text-xs sm:text-sm text-gray-300 leading-relaxed">
              © 2024 E-Title. All rights reserved. | Government of Kenya - Ministry of Lands and Physical Planning
            </p>
          </div>
        </div>
      </footer>
    </div>
    """
  end
end
