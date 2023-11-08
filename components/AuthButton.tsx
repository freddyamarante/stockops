import { createClient } from '@/utils/supabase/server'
import Link from 'next/link'
import { Button } from './ui/button'
import { cookies } from 'next/headers'

export default async function AuthButton() {
  const cookieStore = cookies()
  const supabase = createClient(cookieStore)

  const {
    data: { user },
  } = await supabase.auth.getUser()

  return user ? (
    <div className="flex items-center gap-4">
      Hey, {user.email}!
      <form action="/auth/sign-out" method="post">
        <Button variant="destructive">Logout</Button>
      </form>
    </div>
  ) : (
    <div className="flex justify-center space-x-4">
      <Button asChild variant="outline">
        <Link href="/login">Login</Link>
      </Button>
      <Button asChild>
        <Link href="/register">Register</Link>
      </Button>
    </div>
  )
}
